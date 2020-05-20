# frozen_string_literal: true

module Alchemy
  module Admin
    class LayoutpagesController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_layoutpages

      include Alchemy::Admin::CurrentLanguage

      helper Alchemy::Admin::PagesHelper

      def index
        @layout_pages = Page.layoutpages.where(language: @current_language)
        @languages = Language.on_current_site
      end

      def edit
        @page = Page.find(params[:id])
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, @current_language.id, true)
      end
    end
  end
end
