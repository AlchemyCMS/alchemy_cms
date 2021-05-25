# frozen_string_literal: true

module Alchemy
  module Admin
    module EssencesHelper
      # Renders a thumbnail for given EssencePicture content with correct cropping and size
      def essence_picture_thumbnail(content)
        picture = content.ingredient
        essence = content.essence

        return if picture.nil?

        image_tag(
          essence.thumbnail_url,
          alt: picture.name,
          class: "img_paddingtop",
          title: Alchemy.t(:image_name, name: picture.name),
        )
      end

      # Size value for edit picture dialog
      def edit_picture_dialog_size(content)
        if content.settings[:caption_as_textarea]
          content.settings[:sizes] ? "380x320" : "380x300"
        else
          content.settings[:sizes] ? "380x290" : "380x255"
        end
      end
    end
  end
end
