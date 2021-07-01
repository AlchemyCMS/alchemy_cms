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
        definition.fetch(:ingredients, [])
      end

      # Returns the definition for given ingredient role
      def ingredient_definition_for(role)
        if ingredient_definitions.blank?
          log_warning "Element #{name} is missing the ingredient definition for #{role}"
          nil
        else
          ingredient_definitions.find { |d| d[:role] == role.to_s }
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
        ingredient_by_role(role)&.value.present?
      end

      # Ingredient validation error messages
      #
      # == Error messages are translated via I18n
      #
      # Inside your translation file add translations like:
      #
      #   alchemy:
      #     ingredient_validations:
      #       name_of_the_element:
      #         role_of_the_ingredient:
      #           validation_error_type: Error Message
      #
      # NOTE: +validation_error_type+ has to be one of:
      #
      #   * blank
      #   * taken
      #   * invalid
      #
      # === Example:
      #
      #   de:
      #     alchemy:
      #       ingredient_validations:
      #         contactform:
      #           email:
      #             invalid: 'Die Email hat nicht das richtige Format'
      #
      #
      # == Error message translation fallbacks
      #
      # In order to not translate every single ingredient for every element
      # you can provide default error messages per content name:
      #
      # === Example
      #
      #   en:
      #     alchemy:
      #       ingredient_validations:
      #         fields:
      #           email:
      #             invalid: E-Mail has wrong format
      #             blank: E-Mail can't be blank
      #
      # And even further you can provide general field agnostic error messages:
      #
      # === Example
      #
      #   en:
      #     alchemy:
      #       ingredient_validations:
      #         errors:
      #           invalid: %{field} has wrong format
      #           blank: %{field} can't be blank
      #
      def ingredient_error_messages
        messages = []
        ingredients_with_errors.map { |i| [i.role, i.errors.details] }.each do |role, error_details|
          error_details[:value].each do |error_detail|
            error = error_detail[:error]
            messages << Alchemy.t(
              "#{name}.#{role}.#{error}",
              scope: "ingredient_validations",
              default: [
                "fields.#{role}.#{error}".to_sym,
                "errors.#{error}".to_sym,
              ],
              field: Alchemy::Ingredient.translated_label_for(role, name),
            )
          end
        end
        messages
      end

      private

      # Builds ingredients for this element as described in the +elements.yml+
      def build_ingredients
        self.ingredients = ingredient_definitions.map do |attributes|
          Ingredient.build(role: attributes[:role], element: self)
        end
      end
    end
  end
end
