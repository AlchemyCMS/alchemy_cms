# frozen_string_literal: true

module Alchemy
  module Ingredients
    class BaseEditor < ViewComponent::Base
      delegate :definition,
        :element,
        :id,
        :linked?,
        :partial_name,
        :role,
        :settings,
        :value,
        to: :ingredient

      delegate :alchemy,
        :hint_with_tooltip,
        :render_hint_for,
        :render_icon,
        :warning,
        to: :helpers

      attr_reader :ingredient, :element_form, :html_options

      def initialize(ingredient, element_form:, html_options: {})
        raise ArgumentError, "Ingredient missing!" if ingredient.nil?

        @ingredient = ingredient
        @element_form = element_form
        @html_options = html_options
      end

      def call
        tag.div(class: css_classes, data: data_attributes) do
          element_form.fields_for(:ingredients, ingredient) do |form|
            concat ingredient_label
            concat input_field(form)
          end
        end
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

      # Returns a unique string to be passed to a form field id.
      #
      # @param column [String] A Ingredient column_name. Default is 'value'
      #
      def form_field_id(column = "value")
        "element_#{element.id}_ingredient_#{ingredient.id}_#{column}"
      end

      private

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
          default: Alchemy.t("ingredient_roles.#{role}", default: role.humanize)
        )
      end

      def css_classes
        [
          "ingredient-editor",
          partial_name,
          ingredient.deprecated? ? "deprecated" : nil,
          settings[:linkable] ? "linkable" : nil,
          settings[:anchor] ? "with-anchor" : nil
        ].compact
      end

      def data_attributes
        {
          ingredient_id: ingredient.id,
          ingredient_role: role
        }
      end

      def has_warnings?
        definition.blank? || ingredient.deprecated?
      end

      def warnings
        return unless has_warnings?

        if definition.blank?
          Logger.warn("ingredient #{role} is missing its definition", caller(1..1))
          Alchemy.t(:ingredient_definition_missing)
        else
          definition.deprecation_notice(element_name: element&.name)
        end
      end

      def validations
        definition.validate
      end

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

      def length_validation
        validations.select { _1.is_a?(Hash) }.find { _1[:length] }&.fetch(:length)
      end

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

      def form_field_counter
        element.definition.ingredients.index { |i| i.role == role }
      end

      # Renders the translated role of ingredient.
      #
      # Displays a warning icon if ingredient is missing its definition.
      #
      # Displays a mandatory field indicator, if the ingredient has validations.
      #
      def ingredient_role
        content = translated_role

        if has_warnings?
          icon = hint_with_tooltip(warnings)
          content = "#{icon} #{content}".html_safe
        end

        if ingredient.has_validations?
          "#{content}<span class='validation_indicator'>*</span>".html_safe
        else
          content
        end
      end

      # Renders the label and hint for a ingredient.
      def ingredient_label(column = :value)
        label_tag form_field_id(column) do
          concat ingredient_role
          concat render_hint_for(ingredient, size: "1x", fixed_width: false)
        end
      end

      # Renders the input field for the ingredient.
      # Override this method in subclasses to provide custom input fields.
      # For example a text area or a select box.
      #
      def input_field(form)
        tag.div(class: "input-field") do
          form.text_field(:value,
            class: "full_width",
            name: form_field_name,
            id: form_field_id,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            required: presence_validation?,
            pattern: format_validation)
        end
      end
    end
  end
end
