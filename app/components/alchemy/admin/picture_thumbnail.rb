module Alchemy
  module Admin
    class PictureThumbnail < ViewComponent::Base
      attr_reader :picture, :url

      def initialize(picture, size: :medium)
        @picture = picture
        @url = picture.thumbnail_url(size: preview_size(size))
      end

      def call
        content_tag("alchemy-picture-thumbnail") do
          image_tag(url, alt: picture.name)
        end
      end

      private

      def preview_size(size)
        Alchemy::Picture::THUMBNAIL_SIZES.fetch(
          size,
          Alchemy::Picture::THUMBNAIL_SIZES[:medium]
        )
      end
    end
  end
end
