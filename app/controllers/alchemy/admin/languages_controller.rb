module Alchemy
  module Admin
    class LanguagesController < Alchemy::Admin::ResourcesController

      def new
        @language = Alchemy::Language.new
        @language.page_layout = (configured_page_layout or @language.page_layout)
      end

    protected

      def configured_page_layout
        Alchemy::Config.get(:default_language).try('[]', 'page_layout')
      end

    end
  end
end
