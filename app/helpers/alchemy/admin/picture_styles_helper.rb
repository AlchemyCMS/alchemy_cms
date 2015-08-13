module Alchemy
  module Admin
    module PictureStylesHelper
      include Alchemy::EssencesHelper
      include Alchemy::Admin::ContentsHelper

      def picture_thumbnail(picture_style, options)
        return unless picture_style.picture.present?

        image_options = {
          size: thumbnail_size(picture_style, options),
          upsample: picture_style.content.settings_value(:upsample, options),
          crop: crop_thumbnail?(picture_style, options) ? 'crop' : nil
        }

        if crop_thumbnail?(picture_style, options)
          image_options[:crop_from] = picture_style.crop_from
          image_options[:crop_size] = picture_style.crop_size
        end

        image_tag(
          alchemy.thumbnail_path({
            id: picture_style.picture.id,
            name: picture_style.picture.urlname,
            sh: picture_style.picture.security_token(image_options)
          }.merge(image_options)),

          alt: picture_style.essence.try(:name),
          class: 'img_paddingtop',
          title: _t(:image_name) + ": #{picture_style.essence.try(:name)}"
        )
      end

      # Size value for edit picture dialog
      def edit_picture_dialog_size(content, options = {})
        if content.settings_value(:caption_as_textarea, options)
          content.settings_value(:sizes, options) ? '380x320' : '380x300'
        else
          content.settings_value(:sizes, options) ? '380x290' : '380x255'
        end
      end

      private

      def thumbnail_size(picture_style, options)
        size_parameters = if picture_style.render_size.present?
          [picture_style.render_size, crop_thumbnail?]
        else
          picture_style.content.settings_value(:size, options)
        end
        picture_style.thumbnail_size(size_parameters)
      end

      def crop_thumbnail?(picture_style, options)
        picture_style.crop? || crop_content_settings?(picture_style, options)
      end

      def crop_content_settings?(picture_style, options)
        ['true', true].include?(picture_style.content.settings_value(:crop, options))
      end
    end
  end
end
