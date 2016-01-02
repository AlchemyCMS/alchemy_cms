module Alchemy
  module Admin
    class LanguagesController < ResourcesController

      def new
        @language = Language.new
        @language.page_layout = configured_page_layout || @language.page_layout
      end

      def switch
        set_alchemy_language(params[:language_id])
        do_redirect_to request.referer
      end

      private

      def configured_page_layout
        Config.get(:default_language).try('[]', 'page_layout')
      end
    end
  end
end
