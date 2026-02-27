module Alchemy
  module Ingredients
    class ColorView < BaseView
      def call
        value.html_safe
      end

      def render?
        !value.nil?
      end
    end
  end
end
