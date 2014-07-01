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

    private

    def resource_params
      params.require(:node).permit(:parent_id, :language_id, :name, :url, :title, :nofollow)
    end

  end
end
