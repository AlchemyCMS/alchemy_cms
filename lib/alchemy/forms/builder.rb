# frozen_string_literal: true

module Alchemy
  module Forms
    class Builder < SimpleForm::FormBuilder
      # Renders a simple_form input, but uses input alchemy_wrapper
      #
      def input(attribute_name, options = {}, &block)
        options[:wrapper] = :alchemy

        if object.respond_to?(:attribute_fixed?) && object.attribute_fixed?(attribute_name)
          tooltip_options = {
            content: Alchemy.t(:attribute_fixed, attribute: attribute_name),
            class: "like-hint-tooltip",
            placement: "bottom-start"
          }
          template.content_tag(:div, class: "input") do
            label(attribute_name) +
              template.content_tag("sl-tooltip", tooltip_options) do
                input_field(attribute_name, disabled: true)
              end
          end
        else
          track_displayed_errors(attribute_name, options)
          super
        end
      end

      # Full messages of all errors that no input of this form displays.
      #
      def undisplayed_error_messages
        return [] unless object.respond_to?(:errors)

        object.errors.objects.reject { |error| displayed_error?(error) }.map(&:full_message)
      end

      # Renders a simple_form input that displays a datepicker
      #
      def datepicker(attribute_name, options = {})
        type = options[:as] || :date
        value = options.fetch(:input_html, {}).delete(:value)
        date = value || object.send(attribute_name.to_sym).presence
        date = Time.zone.parse(date) if date.is_a?(String)

        input_options = {
          type: :text,
          class: type,
          value: date&.iso8601
        }.merge(options[:input_html] || {})

        date_field = input attribute_name, as: :string, input_html: input_options
        template.content_tag("alchemy-datepicker", date_field, "input-type" => type)
      end

      # Renders a simple_form input that displays a richtext editor
      #
      def richtext(attribute_name, options = {})
        text_area = input(attribute_name, options.merge(as: :text))
        template.content_tag("alchemy-tinymce", text_area)
      end

      # Renders a button tag wrapped in a div with 'submit' class.
      #
      def submit(label, options = {})
        options = {
          wrapper_html: {class: "submit"},
          input_html: {is: "alchemy-button"}
        }.update(options)
        template.content_tag("div", options.delete(:wrapper_html)) do
          template.button_tag(label, options.delete(:input_html))
        end
      end

      protected

      def displayed_errors
        @_displayed_errors ||= []
      end

      private

      # Nested +fields_for+ builders record on the root builder, because nested
      # record errors end up on the root object.
      def root_builder
        builder = self
        builder = builder.options[:parent_builder] while builder.options[:parent_builder]
        builder
      end

      def track_displayed_errors(attribute_name, options)
        return if options[:error] == false

        root_builder.displayed_errors << [object, attribute_name.to_sym]
        if options[:reflection]
          root_builder.displayed_errors << [object, options[:reflection].name]
        end
      end

      def displayed_error?(error)
        error = error.inner_error while error.respond_to?(:inner_error)
        displayed_errors.any? do |record, attribute|
          record.equal?(error.base) && attribute == error.attribute
        end
      end
    end
  end
end
