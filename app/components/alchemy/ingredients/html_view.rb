module Alchemy
  module Ingredients
    class HtmlView < BaseView
      def call
        value.to_s.html_safe
      end
    end
  end
end
