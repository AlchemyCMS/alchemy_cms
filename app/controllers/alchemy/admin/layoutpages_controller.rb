# frozen_string_literal: true

module Alchemy
  module Admin
    class LayoutpagesController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_layoutpages
      helper Alchemy::Admin::PagesHelper

      def index
        @layout_root = Page.find_or_create_layout_root_for(Language.current.id)
        @languages = Language.on_current_site
      end

      def edit
        @page = Page.find(params[:id])
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, true)
      end
    end
  end
end
