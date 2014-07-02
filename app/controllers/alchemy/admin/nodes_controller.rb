module Alchemy
  class Admin::NodesController < Admin::ResourcesController

    def index
      @root_nodes = Node.language_root_nodes
      if @root_nodes.blank?
        @root_nodes = [Node.create_language_root_node!]
      end
    end

    def new
      @node = Node.new(parent_id: params[:parent_id], language: Language.current)
    end

    def create
      @node = Node.create(resource_params)
      if resource_params[:navigatable_id] == 'create'
        @node.create_navigatable!
      end
      render_errors_or_redirect(
        @node,
        admin_nodes_path,
        flash_notice_for_resource_action
      )
    end

    def update
      @node.update(resource_params)
      render_errors_or_redirect(
        @node,
        admin_nodes_path,
        flash_notice_for_resource_action
      )
    end

    private

    def resource_params
      params.require(:node).permit(
        :parent_id,
        :language_id,
        :name,
        :url,
        :title,
        :nofollow,
        :navigatable_type,
        :navigatable_id
      )
    end

  end
end
