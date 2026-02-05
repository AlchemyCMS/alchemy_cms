# frozen_string_literal: true

module Alchemy
  module Admin
    class ElementEditor < ViewComponent::Base
      with_collection_parameter :element

      attr_reader :element, :created, :parent_element

      delegate :compact?, :definition, :fixed?, :folded?, :id, :ingredient_definitions,
        :name, :nestable_elements, :all_nested_elements, :taggable?, :public?, :deprecated?,
        to: :element

      delegate :alchemy, :cannot?, :render_icon, :render_message, to: :helpers

      def initialize(element:, created: false, parent_element: nil)
        @element = element
        @created = created
        @parent_element = parent_element
      end

      # CSS classes for the element editor.
      def css_classes
        [
          "element-editor",
          ingredient_definitions.present? ? "with-ingredients" : "without-ingredients",
          nestable_elements.any? ? "nestable" : "not-nestable",
          taggable? ? "taggable" : "not-taggable",
          folded? ? "folded" : "expanded",
          compact? ? "compact" : nil,
          deprecated? ? "deprecated" : nil,
          fixed? ? "is-fixed" : "not-fixed",
          public? ? nil : "element-hidden"
        ]
      end

      # Tells us, if we should show the element footer and form inputs.
      def editable?
        ingredient_definitions.any? || taggable?
      end

      # Are any ingredients defined?
      # @return [Boolean]
      def has_ingredients_defined?
        ingredient_definitions.any?
      end

      # Returns ingredient instances for defined ingredients
      #
      # Creates ingredient on demand if the ingredient is not yet present on the element
      #
      # @return Array<Alchemy::Ingredient>
      def ingredients
        ingredient_definitions.map do |ingredient|
          find_or_create_ingredient(ingredient)
        end
      end

      # Returns ingredients that are not part of any group
      def ungrouped_ingredients
        ingredients.reject { _1.definition.group }
      end

      # Returns ingredients grouped by their group name
      #
      # @return [Hash<String, Array<Alchemy::Ingredient>>]
      def grouped_ingredients
        ingredients.select { _1.definition.group }.group_by { _1.definition.group }
      end

      # Returns the translated ingredient group for displaying in admin editor group headings
      #
      # Translate it in your locale yml file:
      #
      #   alchemy:
      #     element_groups:
      #       foo: Bar
      #
      # Optionally you can scope your ingredient role to an element:
      #
      #   alchemy:
      #     element_groups:
      #       article:
      #         foo: Baz
      #
      def translated_group(group)
        Alchemy.t(
          group,
          scope: "element_groups.#{element.name}",
          default: Alchemy.t("element_groups.#{group}", default: group.humanize)
        )
      end

      def display_name
        parent_element ?
          "#{parent_element.display_name} > #{element.display_name}"
          : element.display_name
      end

      private

      def find_or_create_ingredient(definition)
        element.ingredients.detect { _1.role == definition.role } ||
          element.ingredients.create!(
            role: definition.role,
            type: Alchemy::Ingredient.normalize_type(definition.type)
          )
      end
    end
  end
end
