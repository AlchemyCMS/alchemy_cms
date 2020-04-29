# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Api::NodesController do
    describe "#move" do
      let!(:root_node) { create(:alchemy_node, name: "main_menu") }
      let!(:page_node) { create(:alchemy_node, :with_page, parent: root_node) }
      let!(:page_node_2) { create(:alchemy_node, :with_page, parent: root_node) }
      let!(:url_node) { create(:alchemy_node, :with_url, parent: root_node) }

      context "with authorized access" do
        before do
          authorize_user(:as_admin)
        end

        it "returns JSON and moves the node" do
          expect(page_node.children).to be_empty
          expect(url_node.lft).to eq(6)
          patch alchemy.move_api_node_path(url_node, format: :json), params: {
            target_parent_id: page_node.id,
            new_position: 0,
          }
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json["parent_id"]).to eq(page_node.id)
          expect(page_node.children).to include(url_node)
        end
      end

      context "with unauthorized access" do
        before do
          authorize_user
        end

        it "returns an unauthorized error" do
          patch alchemy.move_api_node_path(url_node, format: :json), params: {
            target_parent_id: page_node.id,
            new_position: 0,
          }
          expect(response).to be_forbidden
          response_json = JSON.parse(response.body)
          expect(response_json["error"]).to eq("Not authorized")
        end
      end
    end

    describe "#toggle_folded" do
      context "with expanded node" do
        let(:node) { create(:alchemy_node, folded: false) }

        context "with authorized access" do
          before do
            authorize_user(:as_admin)
          end

          it "folds node" do
            expect {
              patch alchemy.toggle_folded_api_node_path(node)
            }.to change { node.reload.folded }.to(true)
          end
        end

        context "with unauthorized access" do
          before do
            authorize_user
          end

          it "returns an unauthorized error" do
            expect {
              patch alchemy.toggle_folded_api_node_path(node)
            }.not_to change { node.reload.folded }

            expect(response).to be_forbidden
            response_json = JSON.parse(response.body)
            expect(response_json["error"]).to eq("Not authorized")
          end
        end
      end

      context "with folded node" do
        let(:node) { create(:alchemy_node, folded: true) }

        before do
          authorize_user(:as_admin)
        end

        it "expands node" do
          expect {
            patch alchemy.toggle_folded_api_node_path(node)
          }.to change { node.reload.folded }.to(false)
        end

        context "with node having children" do
          before do
            create(:alchemy_node, parent: node)
          end

          it "returns success" do
            patch alchemy.toggle_folded_api_node_path(node)
            expect(response).to be_successful
            response_json = JSON.parse(response.body)
            expect(response_json["id"]).to eq(node.id)
          end
        end
      end
    end
  end
end
