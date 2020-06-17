# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Url
      MISSING_IMAGE = "missing-image.jpg"

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
      # @return [String]
      #
      def call(params = {})
        return variant.image.url(params) unless processible_image?

        "/#{uid}"
      end

      private

      def processible_image?
        variant.image.is_a?(::Dragonfly::Job)
      end

      def uid
        signature = PictureThumb::Signature.call(variant)
        thumb = PictureThumb.find_by(signature: signature)
        if thumb
          uid = thumb.uid
        else
          uid = PictureThumb::Uid.call(signature, variant)
          PictureThumb.generator_class.call(variant, signature, uid)
        end
        uid
      rescue ::Dragonfly::Job::Fetch::NotFound => e
        log_warning(e.message)
        MISSING_IMAGE
      end
    end
  end
end
