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
              template.content_tag("wa-tooltip", tooltip_options) do
                input_field(attribute_name, disabled: true)
              end
          end
        else
          super
        end
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
    end
  end
end
