# frozen_string_literal: true

module Alchemy
  module Admin
    # Adapter component for rendering ingredient editors.
    #
    # Handles both deprecated partial-based editors and component based editors.
    # Use with_collection for efficient batch rendering of ingredients.
    #
    # @example Component based editors (no element_form needed)
    #   <%= render Alchemy::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients
    #   ) %>
    #
    # @example With element_form for deprecated partials
    #   <%= render Alchemy::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients,
    #     element_form: f
    #   ) %>
    #
    class IngredientEditor < ViewComponent::Base
      with_collection_parameter :ingredient

      # @param ingredient [Alchemy::Ingredient] The ingredient to render an editor for
      # @param element_form [ActionView::Helpers::FormBuilder, nil] Optional form builder for deprecated partials
      def initialize(ingredient:, element_form: nil)
        @ingredient = ingredient
        @element_form = element_form
      end

      def call
        if has_editor_partial?
          deprecation_notice
          Alchemy::Deprecation.silence do
            render partial: "alchemy/ingredients/#{@ingredient.partial_name}_editor",
              locals: {element_form: @element_form},
              object: Alchemy::IngredientEditor.new(@ingredient)
          end
        else
          render @ingredient.as_editor_component
        end
      end

      private

      def has_editor_partial?
        helpers.lookup_context.template_exists?("alchemy/ingredients/_#{@ingredient.partial_name}_editor")
      end

      def deprecation_notice
        Alchemy::Deprecation.warn <<~WARN
          Ingredient editor partials are deprecated!
          Please create a `#{@ingredient.class.name}Editor` class inheriting from `Alchemy::Ingredients::BaseEditor`.
        WARN
      end
    end
  end
end
