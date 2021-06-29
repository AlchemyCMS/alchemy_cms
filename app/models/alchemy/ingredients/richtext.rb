# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A blob of richtext
    #
    class Richtext < Alchemy::Ingredient
      store_accessor :data,
        :stripped_body,
        :sanitized_body

      before_save :strip_content
      before_save :sanitize_content

      # The first 30 characters of the stripped_body
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        stripped_body.to_s[0..max_length - 1]
      end

      # Returns css class names for the editor textarea.
      def tinymce_class_name
        "has_tinymce#{has_custom_tinymce_config? ? " #{element.name}_#{role}" : ""}"
      end

      def has_tinymce?
        true
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
