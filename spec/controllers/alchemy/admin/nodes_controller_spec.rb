# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  describe Admin::NodesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    describe '#index' do
      context 'if root nodes present' do
        let!(:root_node)  { create(:alchemy_node) }
        let!(:child_node) { create(:alchemy_node, parent_id: root_node.id) }

        it "loads only root nodes from current language" do
          get :index
          expect(assigns('root_nodes').to_a).to eq([root_node])
          expect(assigns('root_nodes').to_a).to_not eq([child_node])
        end
      end
    end

    describe '#new' do
      it "sets the current language on new node" do
        get :new
        expect(assigns('node').language).to eq(Language.current)
      end

      context 'with parent id in params' do
        it "sets it to new node" do
          get :new, params: { parent_id: 1 }
          expect(assigns('node').parent_id).to eq(1)
        end
      end
    end

    describe '#create' do
      context 'with valid params' do
        let(:language) { create(:alchemy_language) }

        it "creates node and redirects to index" do
          expect {
            post :create, params: { node: { name: 'Node', language_id: language.id, site_id: language.site_id } }
          }.to change { Alchemy::Node.count }.by(1)
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    describe '#update' do
      let(:node) { create(:alchemy_node) }

      context 'with valid params' do
        it "redirects to nodes path" do
          put :update, params: { id: node.id, node: { name: 'Node'} }
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    describe '#toggle' do
      context 'with expanded node' do
        let(:node) { create(:alchemy_node, folded: false) }

        it "folds node" do
          expect {
            patch :toggle, params: { id: node.id }
          }.to change { node.reload.folded }.to(true)
        end
      end

      context 'with folded node' do
        let(:node) { create(:alchemy_node, folded: true) }

        it "expands node" do
          expect {
            patch :toggle, params: { id: node.id }
          }.to change { node.reload.folded }.to(false)
        end

        context 'with node having children' do
          before do
            create(:alchemy_node, parent: node)
          end

          render_views

          it "returns nodes children" do
            patch :toggle, params: { id: node.id }
            expect(response.body).to have_selector('li .sitemap_node')
          end
        end
      end
    end
  end
end
