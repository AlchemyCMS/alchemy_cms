# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A blob of richtext
    #
    class Richtext < Alchemy::Ingredient
      ingredient_attributes(
        :stripped_body,
        :sanitized_body,
      )

      before_save :strip_content
      before_save :sanitize_content

      # Returns css class names for the editor textarea.
      def tinymce_class_name
        "has_tinymce#{has_custom_tinymce_config? ? " #{element.name}_#{role}" : ""}"
      end

      private

      def strip_content
        self.stripped_body = Rails::Html::FullSanitizer.new.sanitize(value)
      end

      def sanitize_content
        self.sanitized_body = Rails::Html::SafeListSanitizer.new.sanitize(
          value,
          sanitizer_settings
        )
      end

      def sanitizer_settings
        settings[:sanitizer] || {}
      end

      # Returns true if there is a tinymce setting defined that contains settings.
      def has_custom_tinymce_config?
        settings[:tinymce].is_a?(Hash)
      end
    end
  end
end
