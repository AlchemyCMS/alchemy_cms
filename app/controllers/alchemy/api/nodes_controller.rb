# frozen_string_literal: true

module Alchemy
  class Api::NodesController < Api::BaseController
    before_action :load_node
    before_action :authorize_access, only: [:move, :toggle_folded]

    def move
      target_parent_node = Node.find(params[:target_parent_id])
      @node.move_to_child_with_index(target_parent_node, params[:new_position])
      render json: @node, serializer: NodeSerializer
    end

    def toggle_folded
      @node.update(folded: !@node.folded)
      render json: @node, serializer: NodeSerializer
    end

    private

    def load_node
      @node = Node.find(params[:id])
    end

    def authorize_access
      authorize! :update, @node
    end
  end
end
