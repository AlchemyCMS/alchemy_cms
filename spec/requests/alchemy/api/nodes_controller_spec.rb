# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  describe Api::NodesController do
    describe '#move' do
      let!(:root_node) { create(:alchemy_node, name: 'main_menu') }
      let!(:page_node) { create(:alchemy_node, :with_page, parent: root_node) }
      let!(:page_node_2) { create(:alchemy_node, :with_page, parent: root_node) }
      let!(:url_node) { create(:alchemy_node, :with_url, parent: root_node) }

      it 'returns JSON and moves the node' do
        expect(page_node.children).to be_empty
        expect(url_node.lft).to eq(6)
        patch alchemy.move_api_node_path(url_node, format: :json), params: {
          target_parent_id: page_node.id,
          new_position: 0
        }
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['parent_id']).to eq(page_node.id)
        expect(page_node.children).to include(url_node)
      end
    end
  end
end
