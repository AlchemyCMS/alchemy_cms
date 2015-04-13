module Alchemy
  module Admin
    class LayoutpagesController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_layoutpages

      def index
        @layoutpages = Page.layoutpages
        @languages = Language.all
      end

      def edit
        @page = Page.find(params[:id])
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, true)
      end
    end
  end
end
