# frozen_string_literal: true

module Alchemy
  module Admin
    class NodesController < Admin::ResourcesController
      def index
        @root_nodes = Node.language_root_nodes
      end

      def new
        @node = Node.new(
          parent_id: params[:parent_id],
          language: Language.current
        )
      end

      def toggle
        node = Node.find(params[:id])
        node.update(folded: !node.folded)
        if node.folded?
          head :ok
        else
          render partial: 'node', collection: node.children.includes(:page, :children)
        end
      end

      def sort
        @sorting = true
        @root_nodes = Node.language_root_nodes
      end

      # Receives a JSON object representing a language tree to be ordered
      # and updates all pages in that language structure to their correct indexes
      def order
        neworders = JSON.parse(params[:set])
        neworders.each do |neworder|
          tree = create_tree(neworder['children'], Node.find(neworder['id']))

          Alchemy::Node.transaction do
            tree.each do |key, node|
              dbitem = Node.find(key)
              dbitem.update_node!(node)
            end
          end
        end

        flash[:notice] = Alchemy.t("Node order saved")
        do_redirect_to admin_nodes_path
      end

      def visit_nodes(nodes, my_left, parent, depth, tree)
        nodes.each do |item|
          my_right = my_left + 1

          if item['children']
            my_right, tree = visit_nodes(item['children'], my_left + 1, item['id'], depth + 1, tree)
          end

          tree[item['id']] = TreeNode.new(my_left, my_right, parent, depth)
          my_left = my_right + 1
        end

        [my_left, tree]
      end

      def create_tree(items, rootnode)
        _, tree = visit_nodes(items, rootnode.lft + 1, rootnode.id, rootnode.depth + 1, {})
        tree
      end

      private

      def resource_params
        params.require(:node).permit(
          :parent_id,
          :language_id,
          :page_id,
          :name,
          :url,
          :title,
          :nofollow,
          :external
        )
      end
    end
  end
end
