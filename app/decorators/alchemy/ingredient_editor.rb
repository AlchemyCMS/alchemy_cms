# frozen_string_literal: true

module Alchemy
  class IngredientEditor < SimpleDelegator
    alias_method :ingredient, :__getobj__

    def to_partial_path
      "alchemy/ingredients/#{partial_name}_editor"
    end

    # Returns the translated role for displaying in labels
    #
    # Translate it in your locale yml file:
    #
    #   alchemy:
    #     ingredient_roles:
    #       foo: Bar
    #
    # Optionally you can scope your ingredient role to an element:
    #
    #   alchemy:
    #     ingredient_roles:
    #       article:
    #         foo: Baz
    #
    def translated_role
      Alchemy.t(
        role,
        scope: "ingredient_roles.#{element.name}",
        default: Alchemy.t("ingredient_roles.#{role}", default: role.humanize),
      )
    end

    def css_classes
      [
        "ingredient-editor",
        partial_name,
        deprecated? ? "deprecated" : nil,
      ].compact
    end

    def data_attributes
      {
        ingredient_id: id,
        ingredient_role: role,
      }
    end

    # Returns a string to be passed to Rails form field tags to ensure it can be used with Rails' nested attributes.
    #
    # === Example:
    #
    #   <%= text_field_tag text_editor.form_field_name, text_editor.value %>
    #
    # === Options:
    #
    # You can pass an Ingredient column_name. Default is 'value'
    #
    # ==== Example:
    #
    #   <%= text_field_tag text_editor.form_field_name(:link), text_editor.value %>
    #
    def form_field_name(column = "value")
      "element[ingredients_attributes][#{form_field_counter}][#{column}]"
    end

    def form_field_id(column = "value")
      "element_ingredients_attributes_#{form_field_counter}_#{column}"
    end

    # Fixes Rails partial renderer calling to_model on the object
    # which reveals the delegated ingredient instead of this decorator.
    def respond_to?(method_name)
      return false if method_name == :to_model

      super
    end

    def has_warnings?
      definition.blank? || deprecated?
    end

    def linked?
      link.try(:present?)
    end

    def warnings
      return unless has_warnings?

      if definition.blank?
        Logger.warn("ingredient #{role} is missing its definition", caller(1..1))
        Alchemy.t(:ingredient_definition_missing)
      else
        deprecation_notice
      end
    end

    # Returns a deprecation notice for ingredients marked deprecated
    #
    # You can either use localizations or pass a String as notice
    # in the ingredient definition.
    #
    # == Custom deprecation notices
    #
    # Use general ingredient deprecation notice
    #
    #     - name: element_name
    #       ingredients:
    #         - role: old_ingredient
    #           type: Text
    #           deprecated: true
    #
    # Add a translation to your locale file for a per ingredient notice.
    #
    #     en:
    #       alchemy:
    #         ingredient_deprecation_notices:
    #           element_name:
    #             old_ingredient: Foo baz widget is deprecated
    #
    # or use the global translation that apply to all deprecated ingredients.
    #
    #     en:
    #       alchemy:
    #         ingredient_deprecation_notice: Foo baz widget is deprecated
    #
    # or pass string as deprecation notice.
    #
    #     - name: element_name
    #       ingredients:
    #         - role: old_ingredient
    #           type: Text
    #           deprecated: This ingredient will be removed soon.
    #
    def deprecation_notice
      case definition[:deprecated]
      when String
        definition[:deprecated]
      when TrueClass
        Alchemy.t(
          role,
          scope: [:ingredient_deprecation_notices, element.name],
          default: Alchemy.t(:ingredient_deprecated),
        )
      end
    end

    private

    def form_field_counter
      element.definition.fetch(:ingredients, []).index { |i| i[:role] == role }
    end
  end
end
