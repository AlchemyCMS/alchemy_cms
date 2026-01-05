# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::NodesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    it_behaves_like "a controller that loads current language"

    it_behaves_like "a controller with clipboard functionality", :node

    describe "#index" do
      context "if no language is present" do
        it "redirects to the language admin" do
          get :index
          expect(response).to redirect_to(admin_languages_path)
        end
      end

      context "if root nodes present" do
        let!(:root_node) { create(:alchemy_node) }
        let!(:child_node) { create(:alchemy_node, parent_id: root_node.id) }

        it "loads only root nodes from current language" do
          get :index
          expect(assigns("root_nodes").to_a).to eq([root_node])
          expect(assigns("root_nodes").to_a).to_not eq([child_node])
        end
      end
    end

    describe "#new" do
      context "if no language is present" do
        it "redirects to the language admin" do
          get :new
          expect(response).to redirect_to(admin_languages_path)
        end
      end

      context "if language is present" do
        let!(:default_language) { create(:alchemy_language) }

        it "sets the current language on new node" do
          get :new
          expect(assigns("node").language).to eq(default_language)
        end

        context "with parent id in params" do
          it "sets it to new node" do
            get :new, params: {parent_id: 1}
            expect(assigns("node").parent_id).to eq(1)
          end
        end
      end
    end

    describe "#create" do
      context "with valid params" do
        let(:language) { create(:alchemy_language) }

        it "creates node and redirects to index" do
          expect {
            post :create, params: {node: {menu_type: "main_menu", language_id: language.id}}
          }.to change { Alchemy::Node.count }.by(1)
          expect(response).to redirect_to(admin_nodes_path)
        end
      end

      context "when paste fails" do
        let!(:default_language) { create(:alchemy_language) }
        let!(:parent_node) { create(:alchemy_node, language: default_language) }
        let(:node_in_clipboard) { create(:alchemy_node, language: default_language) }
        let(:node_params) do
          {
            name: "New Node",
            parent_id: parent_node.id,
            language_id: default_language.id
          }
        end

        before do
          allow(Node).to receive(:copy_and_paste).and_raise(StandardError.new("Copy failed"))
        end

        it "handles the error and renders new template" do
          post :create, params: {
            node: node_params,
            paste_from_clipboard: node_in_clipboard.id
          }

          expect(response).to render_template(:new)
          expect(response).to have_http_status(422)
          expect(flash[:error]).to eq("Copy failed")
        end

        it "sets clipboard items for error rendering" do
          allow_any_instance_of(described_class).to receive(:get_clipboard)
            .with("nodes")
            .and_return([{"id" => node_in_clipboard.id.to_s}])

          post :create, params: {
            node: node_params,
            paste_from_clipboard: node_in_clipboard.id
          }

          expect(controller.send(:clipboard)).to include({"id" => node_in_clipboard.id.to_s})
        end
      end

      context "when paste returns non-persisted node" do
        let!(:default_language) { create(:alchemy_language) }
        let!(:parent_node) { create(:alchemy_node, language: default_language) }
        let(:node_in_clipboard) { create(:alchemy_node, language: default_language) }
        let(:invalid_node) { build(:alchemy_node, name: nil) } # Invalid node that won't be persisted
        let(:node_params) do
          {
            name: "New Node",
            parent_id: parent_node.id,
            language_id: default_language.id
          }
        end

        before do
          allow(Node).to receive(:copy_and_paste).and_return(invalid_node)
          allow_any_instance_of(described_class).to receive(:get_clipboard)
            .with("nodes")
            .and_return([{"id" => node_in_clipboard.id.to_s}])
        end

        it "renders new template with unprocessable entity status" do
          post :create, params: {
            node: node_params,
            paste_from_clipboard: node_in_clipboard.id
          }

          expect(response).to render_template(:new)
          expect(response).to have_http_status(422)
        end
      end

      context "when normal node creation fails" do
        let!(:default_language) { create(:alchemy_language) }
        let!(:parent_node) { create(:alchemy_node, language: default_language) }
        let(:invalid_params) do
          {
            name: "", # Invalid - name is required
            parent_id: parent_node.id,
            language_id: default_language.id
          }
        end

        before do
          allow_any_instance_of(described_class).to receive(:get_clipboard)
            .with("nodes")
            .and_return([])
        end

        it "renders new template with unprocessable entity status" do
          post :create, params: {node: invalid_params}

          expect(response).to render_template(:new)
          expect(response).to have_http_status(422)
        end

        it "loads clipboard items for error rendering" do
          post :create, params: {node: invalid_params}

          expect(controller.send(:clipboard)).to eq([])
        end
      end

      context "clipboard integration workflow" do
        let!(:default_language) { create(:alchemy_language) }
        let!(:parent_node) { create(:alchemy_node, language: default_language) }
        let!(:source_node) { create(:alchemy_node, name: "Source Node", language: default_language) }

        it "supports full copy and paste workflow" do
          expect {
            post :create, params: {
              node: {
                name: "Pasted Node",
                parent_id: parent_node.id,
                language_id: default_language.id
              },
              paste_from_clipboard: source_node.id
            }
          }.to change { Node.count }.by(1)

          # Verify the copied node
          pasted_node = Node.last
          expect(pasted_node.name).to eq("Pasted Node")
          expect(pasted_node.parent).to eq(parent_node)
          expect(pasted_node.language).to eq(default_language)
        end
      end
    end

    describe "#update" do
      let(:node) { create(:alchemy_node) }

      context "with valid params" do
        it "redirects to nodes path" do
          put :update, params: {id: node.id, node: {name: "Node"}}
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    describe "#destroy" do
      let(:node) { create(:alchemy_node) }

      context "as default call (not turbo frame request)" do
        it "calls super (ResourcesController destroy)" do
          # Mock the super call behavior from ResourcesController
          expect_any_instance_of(Alchemy::Admin::ResourcesController).to receive(:destroy).and_call_original

          delete :destroy, params: {id: node.id}
          expect(response).to redirect_to(admin_nodes_path)
        end
      end

      context "as turbo frame request" do
        let!(:page) { create(:alchemy_page, nodes: [node]) }

        it "destroys the node through the page" do
          expect {
            delete :destroy, params: {id: node.id}, xhr: true
          }.to change { Node.count }.by(-1)
        end
      end

      context "as turbo stream call", type: :request do
        let!(:page) { create(:alchemy_page, nodes: [node]) }

        it "removes node and returns the new frame" do
          expect(Alchemy::Node.count).to eq(1)
          delete admin_node_path(node), as: :turbo_stream
          expect(Alchemy::Node.count).to eq(0)
          expect(response.code).to eq("302")
        end
      end
    end
  end
end
