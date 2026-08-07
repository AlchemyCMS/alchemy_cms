# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Api::NodesController do
    describe "#index" do
      context "without a Language present" do
        let(:result) { JSON.parse(response.body) }

        it "returns JSON" do
          get alchemy.api_nodes_path(params: {format: :json})
          expect(result["data"]).to eq([])
        end
      end

      context "with nodes present" do
        let!(:node) { create(:alchemy_node, name: "lol") }
        let!(:node2) { create(:alchemy_node, name: "yup") }
        let!(:node3) { create(:alchemy_node, name: "foo", parent: node) }

        let(:result) { JSON.parse(response.body) }

        it "returns JSON" do
          get alchemy.api_nodes_path(params: {format: :json})
          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")
          expect(result).to have_key("data")
        end

        it "returns all nodes ordered by nesting" do
          get alchemy.api_nodes_path(params: {format: :json})
          expect(result["data"].size).to eq(3)
          expect(result["data"][0]).to match(hash_including("id" => node.id))
          expect(result["data"][1]).to match(hash_including("id" => node3.id))
          expect(result["data"][2]).to match(hash_including("id" => node2.id))
        end

        it "includes meta data" do
          get alchemy.api_nodes_path(params: {format: :json})

          expect(result["data"].size).to eq(3)
          expect(result["meta"]["page"]).to eq(1)
          expect(result["meta"]["per_page"]).to eq(3)
          expect(result["meta"]["total_count"]).to eq(3)
        end

        context "with page param given" do
          before do
            expect(Kaminari.config).to receive(:default_per_page).at_least(:once) { 1 }
          end

          it "returns paginated result" do
            get alchemy.api_nodes_path(params: {format: :json, page: 2})

            expect(result["data"].size).to eq(1)
            expect(result["meta"]["page"]).to eq(2)
            expect(result["meta"]["per_page"]).to eq(1)
            expect(result["meta"]["total_count"]).to eq(3)
          end
        end

        context "with ransack query param given" do
          it "returns filtered result" do
            get alchemy.api_nodes_path(params: {format: :json, filter: {name_eq: "yup"}})

            expect(result["data"].size).to eq(1)
          end
        end

        context "with a language_id given" do
          let(:klingon) { create(:alchemy_language, :klingon) }
          let!(:klingon_node) { create(:alchemy_node, name: "yup", language: klingon) }

          it "returns only nodes for that language" do
            get alchemy.api_nodes_path(params: {format: :json, language_id: klingon.id})

            expect(result["data"].size).to eq(1)
            expect(result["data"].first["id"]).to eq klingon_node.id
          end
        end
      end

      context "with restricted, unpublished and foreign nodes present" do
        let(:result) { JSON.parse(response.body) }

        let(:default_language) { Alchemy::Language.default || create(:alchemy_language) }
        let(:public_page) { create(:alchemy_page, :public, language: default_language) }
        let(:restricted_page) { create(:alchemy_page, :public, :restricted, language: default_language) }
        let(:role_restricted_page) do
          create(:alchemy_page, :public, restricted: true, permitted_roles: %w[restricted_test],
            name: "Role restricted", language: default_language)
        end
        let(:unpublished_page) { create(:alchemy_page, language: default_language) }

        let(:other_site) { create(:alchemy_site) }
        let(:other_site_language) { create(:alchemy_language, :german, site: other_site) }
        let(:hidden_language) { create(:alchemy_language, :klingon, public: false) }

        let!(:public_node) { create(:alchemy_node, page: public_page, name: nil, language: default_language) }
        let!(:external_node) { create(:alchemy_node, :with_url, language: default_language) }
        let!(:restricted_node) { create(:alchemy_node, page: restricted_page, name: nil, language: default_language) }
        let!(:role_restricted_node) { create(:alchemy_node, page: role_restricted_page, name: nil, language: default_language) }
        let!(:unpublished_node) { create(:alchemy_node, page: unpublished_page, name: nil, language: default_language) }
        let!(:other_site_node) { create(:alchemy_node, :with_url, language: other_site_language) }
        let!(:hidden_language_node) { create(:alchemy_node, :with_url, language: hidden_language) }

        context "as guest user" do
          it "only returns current site nodes linking to public unrestricted pages or external urls" do
            get alchemy.api_nodes_path(params: {format: :json})

            expect(result["data"].map { |n| n["id"] }).to match_array([
              public_node.id,
              external_node.id
            ])
          end
        end

        context "as member user" do
          before { authorize_user(build(:alchemy_dummy_user)) }

          it "returns nodes to restricted pages readable with their role, but not those restricted to another role" do
            get alchemy.api_nodes_path(params: {format: :json})

            expect(result["data"].map { |n| n["id"] }).to match_array([
              public_node.id,
              external_node.id,
              restricted_node.id
            ])
          end
        end

        context "as member user with an additional role" do
          before { authorize_user(build(:alchemy_dummy_user, alchemy_roles: %w[member restricted_test])) }

          it "also returns nodes to pages restricted to that role" do
            get alchemy.api_nodes_path(params: {format: :json})

            expect(result["data"].map { |n| n["id"] }).to match_array([
              public_node.id,
              external_node.id,
              restricted_node.id,
              role_restricted_node.id
            ])
          end
        end

        context "as author user" do
          before { authorize_user(build(:alchemy_dummy_user, :as_author)) }

          it "returns all nodes" do
            get alchemy.api_nodes_path(params: {format: :json})

            expect(result["data"].map { |n| n["id"] }).to match_array(Alchemy::Node.pluck(:id))
          end
        end
      end
    end

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
            new_position: 0
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
            new_position: 0
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
