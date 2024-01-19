# frozen_string_literal: true

require "alchemy/scrubbers/safe_list"
module Alchemy
  module Ingredients
    # A blob of richtext
    #
    class Richtext < Alchemy::Ingredient
      store_accessor :data,
        :stripped_body,
        :sanitized_body

      allow_settings %i[
        plain_text
        sanitizer
        tinymce
      ]

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

      def has_tinymce?
        true
      end

      def custom_tinymce_config
        settings[:tinymce] || {}
      end

      private

      def strip_content
        self.stripped_body = Rails::HTML5::FullSanitizer.new.sanitize(value)
      end

      def sanitize_content
        scrubber = Alchemy::Scrubbers::SafeList.new(sanitizer_settings)
        self.sanitized_body = Loofah.html5_fragment(value).scrub!(scrubber).to_html
      end

      def sanitizer_settings
        settings[:sanitizer] || {}
      end
    end
  end
end
