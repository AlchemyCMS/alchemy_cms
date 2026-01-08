# frozen_string_literal: true

module Alchemy
  module Admin
    module IngredientsHelper
      include Alchemy::Admin::BaseHelper

      # Renders the translated role of ingredient.
      #
      # Displays a warning icon if ingredient is missing its definition.
      #
      # Displays a mandatory field indicator, if the ingredient has a presence validation.
      # @deprecated
      def render_ingredient_role(ingredient)
        if ingredient.blank?
          warning("Ingredient is nil")
          return
        end

        content = ingredient.translated_role

        if ingredient.has_warnings?
          icon = hint_with_tooltip(ingredient.warnings)
          content = "#{icon} #{content}".html_safe
        end

        if ingredient.presence_validation?
          "#{content}<span class='validation_indicator'>*</span>".html_safe
        else
          content
        end
      end
      deprecate :render_ingredient_role, deprecator: Alchemy::Deprecation

      # Renders the label and hint for a ingredient.
      # @deprecated
      def ingredient_label(ingredient, column = :value, html_options = {})
        label_tag ingredient.form_field_id(column), html_options do
          [
            render_ingredient_role(ingredient),
            render_hint_for(ingredient, size: "1x", fixed_width: false)
          ].compact.join("&nbsp;").html_safe
        end
      end
      deprecate :ingredient_label, deprecator: Alchemy::Deprecation
    end
  end
end
