module Alchemy
  module Admin
    class PictureThumbnail < ViewComponent::Base
      attr_reader :picture, :size, :css_class, :placeholder

      def initialize(picture, size: :medium, css_class: nil, placeholder: nil)
        @picture = picture
        @size = size
        @css_class = css_class
        @placeholder = placeholder
      end

      def call
        thumbnail_url = picture&.thumbnail_url(size: preview_size)
        if thumbnail_url || placeholder
          content_tag "alchemy-picture-thumbnail", placeholder, {
            src: thumbnail_url,
            name: picture&.description_for(::Alchemy::Current.language) || picture&.name,
            class: css_class
          }
        else
          render Alchemy::Admin::Icon.new("file-damage", size: "xl")
        end
      end

      private

      def preview_size
        Alchemy::Picture::THUMBNAIL_SIZES.fetch(
          size,
          Alchemy::Picture::THUMBNAIL_SIZES[:medium]
        )
      end
    end
  end
end
