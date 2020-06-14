# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Url
      include Alchemy::Logger

      attr_reader :variant

      # @param [Alchemy::PictureVariant]
      #
      def initialize(variant)
        raise ArgumentError, "Variant missing!" if variant.nil?

        @variant = variant
      end

      # The URL to a variant of a picture
      #
      # @param [Hash] params URL params
      #
      # @return [String]
      #
      def call(params = {})
        # Lazy load the processed image
        image = variant.image
        # Get URL from local dragonfly server
        image.url(params)
      rescue ::Dragonfly::Job::Fetch::NotFound => e
        log_warning(e.message)
        "/missing-image.jpg"
      end
    end
  end
end
