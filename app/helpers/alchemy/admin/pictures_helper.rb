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
    end
  end
end
