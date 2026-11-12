# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # The ingredients of an element, keyed by role.
      #
      #   {{ element.ingredients.headline.value }}
      #   {% for ingredient in element.ingredients %}{{ ingredient.role }}{% endfor %}
      class IngredientsDrop < Base
        include Enumerable

        def each(&)
          record.ingredients.map { IngredientDrop.new(_1) }.each(&)
        end

        def size
          record.ingredients.size
        end

        def liquid_method_missing(role)
          ingredient = record.ingredient_by_role(role)
          ingredient ? IngredientDrop.new(ingredient) : super
        end
      end
    end
  end
end
