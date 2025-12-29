# frozen_string_literal: true

module Alchemy
  class ElementEditor < SimpleDelegator
    alias_method :element, :__getobj__

    def to_partial_path
      "alchemy/admin/elements/element"
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

    # Are any ingredients defined?
    # @return [Boolean]
    def has_ingredients_defined?
      ingredient_definitions.any?
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

    # CSS classes for the element editor partial.
    def css_classes
      [
        "element-editor",
        ingredient_definitions.present? ? "with-ingredients" : "without-ingredients",
        nestable_elements.any? ? "nestable" : "not-nestable",
        taggable? ? "taggable" : "not-taggable",
        folded ? "folded" : "expanded",
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

    # Fixes Rails partial renderer calling to_model on the object
    # which reveals the delegated element instead of this decorator.
    def respond_to?(*args, **kwargs)
      method_name = args.first
      return false if method_name == :to_model

      super
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
