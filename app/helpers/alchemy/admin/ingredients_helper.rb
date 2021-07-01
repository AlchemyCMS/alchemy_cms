# frozen_string_literal: true

module Alchemy
  module Admin
    module IngredientsHelper
      include Alchemy::Admin::BaseHelper

      # Renders the translated role of ingredient.
      #
      # Displays a warning icon if ingredient is missing its definition.
      #
      # Displays a mandatory field indicator, if the ingredient has validations.
      #
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

        if ingredient.has_validations?
          "#{content}<span class='validation_indicator'>*</span>".html_safe
        else
          content
        end
      end

      # Renders the label and hint for a ingredient.
      def ingredient_label(ingredient, column = :value)
        label_tag ingredient.form_field_id(column) do
          [render_ingredient_role(ingredient), render_hint_for(ingredient)].compact.join("&nbsp;").html_safe
        end
      end
    end
  end
end
