# frozen_string_literal: true

module Alchemy
  module Ingredients
    class ColorEditor < BaseEditor
      def input_field
        content_tag("alchemy-color-select") do
          if colors.present?
            concat select_tag(form_field_name, color_options, disabled: !editable?)
          end
          concat color_field_tag(form_field_name, value, disabled: disabled?)
        end
      end

      private

      def color_value
        @_color_value ||= begin
          current_value = value.presence || settings[:default]
          if current_value.present?
            unknown_color = with_custom_color? && colors.none? { color_settings(_1)[:value] == current_value }
            unknown_color ? "custom_color" : current_value
          elsif with_custom_color?
            "custom_color"
          end
        end
      end

      def color_options
        colors.map do |color|
          name, value, swatch = color_settings(color).values_at(:name, :value, :swatch)
          selected = value == color_value
          content_tag(:option, name, value:, selected:, data: {swatch:})
        end.join.html_safe
      end

      def color_settings(color)
        case color
        when Hash
          color.symbolize_keys.tap { |c| c[:swatch] ||= c[:value] }
        when Array
          {name: color[0], value: color[1], swatch: color[2] || color[1]}
        else
          {name: color, value: color, swatch: color}
        end
      end

      def colors
        @_colors ||= begin
          @_colors = settings.fetch(:colors, [])
          if with_custom_color?
            @_colors << [Alchemy.t(:custom_color), "custom_color"]
          end
          @_colors
        end
      end

      def with_custom_color?
        settings[:custom_color]
      end

      def disabled?
        !editable? || (color_value != "custom_color" && colors.present?)
      end
    end
  end
end
