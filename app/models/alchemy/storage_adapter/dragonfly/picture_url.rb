# frozen_string_literal: true

module Alchemy
  class StorageAdapter
    class Dragonfly::PictureUrl
      TRANSFORMATION_OPTIONS = [
        :crop,
        :crop_from,
        :crop_size,
        :flatten,
        :format,
        :quality,
        :size,
        :upsample
      ]

      attr_reader :picture, :variant, :thumb

      # @param [Alchemy::Picture]
      #
      def initialize(picture)
        @picture = picture
      end

      # The URL to a variant of a picture
      #
      # @return [String]
      #
      def call(variant_options = {})
        set_variant(variant_options)

        params = {
          basename: picture.name,
          ext: variant.render_format,
          name: picture.name
        }

        return variant.image.url(params) unless processible_image?

        "/#{uid}"
      end

      private

      def set_variant(options = {})
        @variant = PictureVariant.new(picture, options.slice(*TRANSFORMATION_OPTIONS))
      end

      def processible_image?
        variant.image.is_a?(::Dragonfly::Job)
      end

      def uid
        signature = PictureThumb::Signature.call(variant)
        if find_thumb_by(signature)
          thumb.uid
        else
          uid = PictureThumb::Uid.call(signature, variant)
          ActiveRecord::Base.connected_to(role: ActiveRecord.writing_role) do
            PictureThumb::Create.call(variant, signature, uid)
          end
          uid
        end
      end

      def find_thumb_by(signature)
        @thumb = if picture.thumbs.loaded?
          picture.thumbs.find { |t| t.signature == signature }
        else
          picture.thumbs.find_by(signature: signature)
        end
      end
    end
  end
end
