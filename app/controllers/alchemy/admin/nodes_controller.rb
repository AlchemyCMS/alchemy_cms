module Alchemy
  class Admin::NodesController < Admin::ResourcesController

    def index
      @nodes = Node.language_root_nodes
    end

    def new
      @node = Node.new(parent_id: params[:parent_id], language: Language.current)
    end

    def create
      @node = Node.create(resource_params)

      render_errors_or_redirect @node,
        admin_nodes_path,
        flash_notice_for_resource_action
    end

    def update
      @node.update(resource_params)

      render_errors_or_redirect @node,
        admin_nodes_path,
        flash_notice_for_resource_action
    end

    # TODO: Implement Node#fold
    # def fold
    #   # @page is fetched via before filter
    #   @page.fold!(current_alchemy_user.id, !@page.folded?(current_alchemy_user.id))
    #   respond_to do |format|
    #     format.js
    #   end
    # end

    # TODO: Implement Node#sort
    # def sort
    #   @sorting = true
    # end

    # TODO: Implement Node#order
    # # Receives a JSON object representing a language tree to be ordered
    # # and updates all pages in that language structure to their correct indexes
    # def order
    #   neworder = JSON.parse(params[:set])
    #   tree = create_tree(neworder, @page_root)
    #
    #   Page.transaction do
    #     tree.each do |key, node|
    #       dbitem = Page.find(key)
    #       dbitem.update_node!(node)
    #     end
    #   end
    #
    #   flash[:notice] = _t("Pages order saved")
    #   do_redirect_to admin_pages_path
    # end

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
