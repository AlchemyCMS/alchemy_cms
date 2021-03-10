# frozen_string_literal: true

module Alchemy
  module Admin
    module PicturesHelper
      def preview_size(size)
        Alchemy::Picture::THUMBNAIL_SIZES.fetch(
          size,
          Alchemy::Picture::THUMBNAIL_SIZES[:medium]
        )
      end

      def picture_thumbnail(image)
        picture = image

        return if picture.nil?

        image_tag(
          picture.url,
          alt: picture.name,
          class: "img_paddingtop",
          title: Alchemy.t(:image_name) + ": #{picture.name}",
        )
      end
    end
  end
end
