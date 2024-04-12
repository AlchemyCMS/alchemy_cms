module Alchemy
  module Ingredients
    class BooleanView < BaseView
      def call
        Alchemy.t(value.to_s, scope: "ingredient_values.boolean").html_safe
      end

      def render?
        !value.nil?
      end
    end
  end
end
