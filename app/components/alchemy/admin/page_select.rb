module Alchemy
  module Admin
    class PageSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      def initialize(page = nil, url: nil, allow_clear: false, placeholder: Alchemy.t(:search_page), query_params: nil)
        @page = page
        @url = url
        @allow_clear = allow_clear
        @placeholder = placeholder
        @query_params = query_params
      end

      def call
        content_tag("alchemy-page-select", content, attributes)
      end

      private

      def attributes
        options = {
          placeholder: @placeholder,
          url: @url || alchemy.api_pages_path
        }

        options = options.merge({"allow-clear": @allow_clear}) if @allow_clear
        options = options.merge({"query-params": @query_params.to_json}) if @query_params

        if @page
          selection = {
            id: @page.id,
            name: @page.name,
            url_path: @page.url_path
          }
          options = options.merge({selection: selection.to_json})
        end

        options
      end
    end
  end
end
