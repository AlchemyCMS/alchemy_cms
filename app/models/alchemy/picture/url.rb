# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Url
      attr_reader :variant, :thumb

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
        if find_thumb_by(signature)
          thumb.uid
        else
          uid = PictureThumb::Uid.call(signature, variant)
          ActiveRecord::Base.connected_to(role: ActiveRecord::Base.writing_role) do
            PictureThumb.generator_class.call(variant, signature, uid)
          end
          uid
        end
      end

      def find_thumb_by(signature)
        @thumb = if variant.picture.thumbs.loaded?
            variant.picture.thumbs.find { |t| t.signature == signature }
          else
            variant.picture.thumbs.find_by(signature: signature)
          end
      end
    end
  end
end
