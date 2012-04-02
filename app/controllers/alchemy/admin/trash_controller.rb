module Alchemy
  module Admin
    class TrashController < Alchemy::Admin::BaseController

      helper "alchemy/admin/elements"

      def index
        @elements = Element.trashed
        @page = Page.find_by_id(params[:page_id])
        @allowed_elements = Element.all_for_page(@page)
        @draggable_trash_items = {}
        @elements.each { |e| @draggable_trash_items["element_#{e.id}"] = e.belonging_cellnames(@page) }
        render :layout => false
      end

      def clear
        @page = Page.find_by_id(params[:page_id])
        @elements = Element.trashed
        @elements.map(&:destroy)
      end

    end
  end
end
