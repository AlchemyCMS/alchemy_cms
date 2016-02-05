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

    end
  end
end
