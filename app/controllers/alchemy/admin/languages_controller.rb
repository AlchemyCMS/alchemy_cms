# frozen_string_literal: true

module Alchemy
  module Admin
    class LanguagesController < ResourcesController
      def index
        @query = Language.on_current_site.ransack(search_filter_params[:q])
        @languages = @query.result.page(params[:page] || 1).per(items_per_page)
      end

      def new
        @language = Language.new(
          page_layout: Config.get(:default_language)['page_layout']
        )
      end
    end
  end
end
