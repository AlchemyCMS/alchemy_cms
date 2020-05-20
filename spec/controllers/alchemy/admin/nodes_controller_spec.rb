# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::NodesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    describe "#index" do
      context "if no language is present" do
        it "redirects to the language admin" do
          get :index
          expect(response).to redirect_to(admin_languages_path)
        end
      end

      context "if root nodes present" do
        let!(:root_node)  { create(:alchemy_node) }
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
            get :new, params: { parent_id: 1 }
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
            post :create, params: { node: { menu_type: "main_menu", language_id: language.id } }
          }.to change { Alchemy::Node.count }.by(1)
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    describe "#update" do
      let(:node) { create(:alchemy_node) }

      context "with valid params" do
        it "redirects to nodes path" do
          put :update, params: { id: node.id, node: { name: "Node"} }
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end
  end
end
