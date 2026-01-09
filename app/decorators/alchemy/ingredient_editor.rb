# frozen_string_literal: true

module Alchemy
  class IngredientEditor < SimpleDelegator
    alias_method :ingredient, :__getobj__

    # @deprecated
    def to_partial_path
      "alchemy/ingredients/#{partial_name}_editor"
    end
    deprecate :to_partial_path, deprecator: Alchemy::Deprecation

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
    # @deprecated
    def translated_role
      Alchemy.t(
        role,
        scope: "ingredient_roles.#{element.name}",
        default: Alchemy.t("ingredient_roles.#{role}", default: role.humanize)
      )
    end
    deprecate translated_role: "Use Ingredient#translated_role instead", deprecator: Alchemy::Deprecation

    # @deprecated
    def css_classes
      [
        "ingredient-editor",
        partial_name,
        deprecated? ? "deprecated" : nil,
        (respond_to?(:level_options) && level_options.any?) ? "with-level-select" : nil,
        (respond_to?(:size_options) && size_options.many?) ? "with-size-select" : nil,
        settings[:linkable] ? "linkable" : nil,
        settings[:anchor] ? "with-anchor" : nil
      ].compact
    end
    deprecate :css_classes, deprecator: Alchemy::Deprecation

    # @deprecated
    def data_attributes
      {
        ingredient_id: id,
        ingredient_role: role
      }
    end
    deprecate :data_attributes, deprecator: Alchemy::Deprecation

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
    # @deprecated
    def form_field_name(column = "value")
      "element[ingredients_attributes][#{form_field_counter}][#{column}]"
    end
    deprecate :form_field_name, deprecator: Alchemy::Deprecation

    # Returns a unique string to be passed to a form field id.
    #
    # @param column [String] A Ingredient column_name. Default is 'value'
    # @deprecated
    def form_field_id(column = "value")
      "element_#{element.id}_ingredient_#{id}_#{column}"
    end
    deprecate :form_field_id, deprecator: Alchemy::Deprecation

    # Fixes Rails partial renderer calling to_model on the object
    # which reveals the delegated ingredient instead of this decorator.
    def respond_to?(method_name)
      return false if method_name == :to_model

      super
    end

    # @deprecated
    def has_warnings?
      definition.blank? || deprecated?
    end
    deprecate :has_warnings?, deprecator: Alchemy::Deprecation

    # @deprecated
    def linked?
      link.try(:present?)
    end
    deprecate :linked?, deprecator: Alchemy::Deprecation

    # @deprecated
    def warnings
      return unless has_warnings?

      if definition.blank?
        Logger.warn("ingredient '#{role}' is missing its definition! Please check your element definitions.")
        Alchemy.t(:ingredient_definition_missing)
      else
        definition.deprecation_notice(element_name: element&.name)
      end
    end
    deprecate :warnings, deprecator: Alchemy::Deprecation

    # @deprecated
    def validations
      definition.validate
    end
    deprecate :validations, deprecator: Alchemy::Deprecation

    # @deprecated
    def format_validation
      format = validations.select { _1.is_a?(Hash) }.find { _1[:format] }&.fetch(:format)
      return nil unless format

      # If format is a string or symbol, resolve it from config format_matchers
      if format.is_a?(String) || format.is_a?(Symbol)
        Alchemy.config.format_matchers.get(format)
      else
        format
      end
    end
    deprecate :format_validation, deprecator: Alchemy::Deprecation

    # @deprecated
    def length_validation
      validations.select { _1.is_a?(Hash) }.find { _1[:length] }&.fetch(:length)
    end
    deprecate :length_validation, deprecator: Alchemy::Deprecation

    # @deprecated
    def presence_validation?
      validations.any? do |validation|
        case validation
        when :presence, "presence"
          true
        when Hash
          validation[:presence] == true || validation["presence"] == true
        else
          false
        end
      end
    end
    deprecate :presence_validation?, deprecator: Alchemy::Deprecation

    private

    def form_field_counter
      element.ingredient_definitions.index { _1.role == role }
    end
  end
end
