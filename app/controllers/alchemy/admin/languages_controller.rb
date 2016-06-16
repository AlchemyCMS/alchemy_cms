module Alchemy
  module Admin
    class LanguagesController < ResourcesController
      def index
        @query = Language.on_current_site.ransack(params[:q])
        @languages = @query.result.page(params[:page] || 1).per(per_page_value_for_screen_size)
      end

      def new
        @language = Language.new
        @language.page_layout = configured_page_layout || @language.page_layout
      end

      private

      def configured_page_layout
        Config.get(:default_language).try('[]', 'page_layout')
      end
    end
  end
end
