# frozen_string_literal: true

module Alchemy
  module Ingredients
    class ColorEditor < BaseEditor
      def input_field
        content_tag("alchemy-color-select") do
          if colors.present?
            concat select_tag(form_field_name, options_for_select(colors, color_value))
          end
          concat color_field_tag(form_field_name, value, disabled: disabled?)
        end
      end

      private

      def color_value
        @_color_value ||= begin
          unknown_color = with_custom_color? && colors.none? { |color| color[1] == value }
          unknown_color ? "custom_color" : value
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
        color_value != "custom_color" && colors.present?
      end
    end
  end
end
