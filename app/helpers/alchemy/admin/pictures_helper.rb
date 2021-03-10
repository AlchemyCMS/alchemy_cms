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

      def picture_assignment_redirect_url(picture_to_assign, record, content)
        if content.present?
          alchemy.assign_admin_essence_pictures_path(
            picture_id: picture_to_assign.id,
            content_id: content
          )
        else
          alchemy.assign_admin_pictures_path(
            picture_id: picture_to_assign.id,
            record_id: record.id,
            record_type: record.class.name
          )
        end
      end
    end
  end
end
