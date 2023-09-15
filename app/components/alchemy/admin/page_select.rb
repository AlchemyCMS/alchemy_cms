module Alchemy
  module Admin
    class PageSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      def initialize(page = nil, allow_clear: true, placeholder: Alchemy.t(:search_page))
        @page = page
        @allow_clear = allow_clear
        @placeholder = placeholder
      end

      def call
        content_tag("alchemy-page-select", content, attributes)
      end

      private

      def attributes
        options = {
          placeholder: @placeholder,
          url: alchemy.api_pages_path,
          "allow-clear": @allow_clear
        }

        if @page
          selection = {
            id: @page.id,
            name: @page.name,
            url_path: @page.url_path
          }
          options = options.merge({ selection: selection.to_json })
        end

        options
      end
    end
  end
end
