# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    # Methods concerning ingredients for elements
    #
    module ElementIngredients
      extend ActiveSupport::Concern

      included do
        attr_accessor :autogenerate_ingredients

        has_many :ingredients,
          class_name: "Alchemy::Ingredient",
          inverse_of: :element,
          dependent: :destroy

        before_create :build_ingredients,
          unless: -> { autogenerate_ingredients == false }

        accepts_nested_attributes_for :ingredients
        validates_associated :ingredients, on: :update
      end

      # The value of an ingredient of the element by role
      def value_for(role)
        ingredient_by_role(role)&.value
      end

      # Find first ingredient from element by given role.
      def ingredient_by_role(role)
        ingredients.detect { |ingredient| ingredient.role == role.to_s }
      end

      # Find first ingredient from element by given type.
      def ingredient_by_type(type)
        ingredients_by_type(type).first
      end

      # All ingredients from element by given type.
      def ingredients_by_type(type)
        ingredients.select do |ingredient|
          ingredient.type == Ingredient.normalize_type(type)
        end
      end

      # Copy current ingredient's ingredients to given target element
      def copy_ingredients_to(element)
        ingredients.map do |ingredient|
          Ingredient.copy(ingredient, element_id: element.id)
        end
      end

      # Returns all element ingredient definitions from the +elements.yml+ file
      def ingredient_definitions
        definition.ingredients
      end

      # Returns the definition for given ingredient role
      def ingredient_definition_for(role)
        if ingredient_definitions.blank?
          nil
        else
          ingredient_definitions.find { _1.role == role.to_s } ||
            Logger.warn("Element '#{name}' is missing the ingredient definition for '#{role}'")
        end
      end

      # Returns an array of all Richtext ingredients ids from elements
      #
      # This is used to re-initialize the TinyMCE editor in the element editor.
      #
      def richtext_ingredients_ids
        ids = ingredients.select(&:has_tinymce?).collect(&:id)
        expanded_nested_elements = nested_elements.expanded
        if expanded_nested_elements.present?
          ids += expanded_nested_elements.collect(&:richtext_ingredients_ids)
        end
        ids.flatten
      end

      # Has any of the ingredients validations defined?
      def has_validations?
        ingredients.any?(&:has_validations?)
      end

      # All element ingredients where the validation has failed.
      def ingredients_with_errors
        ingredients.select { |i| i.errors.any? }
      end

      # True if the element has a ingredient for given name
      # that has a non blank value.
      def has_value_for?(role)
        value_for(role).present?
      end

      private

      # Builds ingredients for this element as described in the +elements.yml+
      def build_ingredients
        ingredient_definitions.each do |definition|
          ingredients.build(
            role: definition.role,
            type: Alchemy::Ingredient.normalize_type(definition.type)
          )
        end
      end
    end
  end
end
