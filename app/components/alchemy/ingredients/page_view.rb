module Alchemy
  module Ingredients
    class PageView < BaseView
      delegate :page, to: :ingredient

      def call
        link_to(page.name, alchemy.show_page_path(urlname: page.urlname)).html_safe
      end

      def render?
        !!page
      end
    end
  end
end
