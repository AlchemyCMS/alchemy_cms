# frozen_string_literal: true

module Alchemy
  module Admin
    # Adapter component for rendering ingredient editors.
    #
    # Handles both deprecated partial-based editors and modern ViewComponent editors.
    # Use with_collection for efficient batch rendering of ingredients.
    #
    # @example
    #   <%= render Alchemy::Admin::IngredientEditor.with_collection(
    #     element.ungrouped_ingredients,
    #     element_form: f
    #   ) %>
    #
    class IngredientEditor < ViewComponent::Base
      with_collection_parameter :ingredient

      def initialize(ingredient:, element_form:)
        @ingredient = ingredient
        @element_form = element_form
      end

      def call
        if has_editor_partial?
          deprecation_notice
          render partial: "alchemy/ingredients/#{@ingredient.partial_name}_editor",
            locals: {element_form: @element_form}, object: @ingredient
        else
          render @ingredient.as_editor_component(element_form: @element_form)
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
