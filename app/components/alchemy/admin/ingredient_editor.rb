# frozen_string_literal: true

module Alchemy
  module Admin
    # Adapter component for rendering ingredient editors.
    #
    # Use with_collection for efficient batch rendering of ingredients.
    #
    # @example
    #   <%= render Alchemy::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients
    #   ) %>
    #
    class IngredientEditor < ViewComponent::Base
      with_collection_parameter :ingredient

      # @param ingredient [Alchemy::Ingredient] The ingredient to render an editor for
      def initialize(ingredient:)
        @ingredient = ingredient
      end

      def call
        render @ingredient.as_editor_component
      end
    end
  end
end
