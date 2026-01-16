module Alchemy
  module Ingredients
    class ColorView < BaseView
      def call
        value
      end

      def render?
        !value.nil?
      end
    end
  end
end
