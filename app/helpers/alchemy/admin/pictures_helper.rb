# frozen_string_literal: true

module Alchemy
  module Admin
    module PicturesHelper
      def create_or_assign_url(picture_to_assign, options)
        if @content.nil?
          {
            controller: :contents,
            action: :create,
            picture_id: picture_to_assign.id,
            content: {
              essence_type: "Alchemy::EssencePicture",
              element_id: @element.id
            },
            options: options
          }
        else
          {
            controller: :essence_pictures,
            action: :assign,
            picture_id: picture_to_assign.id,
            content_id: @content.id,
            options: options
          }
        end
      end

      def preview_size(size)
        case size
        when 'small' then '80x60'
        when 'large' then '240x180'
        else
          '160x120'
        end
      end
    end
  end
end
