# frozen_string_literal: true

module Alchemy
  class Api::NodesController < Api::BaseController
    before_action :load_node, except: :index
    before_action :authorize_access, only: [:move, :toggle_folded]

    def index
      @nodes = Node.all
      @nodes = @nodes.includes(:parent)
      @nodes = @nodes.ransack(params[:filter]).result

      if params[:page]
        @nodes = @nodes.page(params[:page]).per(params[:per_page])
      end

      render json: @nodes, adapter: :json, root: "data", meta: meta_data, include: params[:include]
    end

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

    def meta_data
      {
        total_count: total_count_value,
        per_page: per_page_value,
        page: page_value,
      }
    end

    def total_count_value
      params[:page] ? @nodes.total_count : @nodes.size
    end

    def per_page_value
      if params[:page]
        (params[:per_page] || Kaminari.config.default_per_page).to_i
      else
        @nodes.size
      end
    end

    def page_value
      params[:page] ? params[:page].to_i : 1
    end
  end
end
