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
      end

      def update
        @page = Page.find(params[:id])
        if @page.update(page_params)
          @notice = Alchemy.t("Page saved", name: @page.name)
          render "alchemy/admin/pages/update"
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def page_params
        params.require(:page).permit(
          :name,
          :tag_list
        )
      end
    end
  end
end
