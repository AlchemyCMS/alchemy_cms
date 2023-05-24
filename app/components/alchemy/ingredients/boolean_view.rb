module Alchemy
  module Ingredients
    class BooleanView < BaseView
      def call
        Alchemy.t(value, scope: "ingredient_values.boolean")
      end

      def render?
        !value.nil?
      end
    end
  end
end
