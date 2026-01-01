# frozen_string_literal: true

module Alchemy
  module Ingredients
    class PictureEditor < BaseEditor
      delegate :allow_image_cropping?,
        :css_class,
        :image_file_width,
        :image_file_height,
        :picture,
        :thumbnail_url_options,
        to: :ingredient

      def input_field
        content_tag("alchemy-picture-editor") do
          concat(
            tag.div(class: "picture_thumbnail",
              data: {
                target_size: settings[:size] || [
                  image_file_width.to_i,
                  image_file_height.to_i
                ].join("x"),
                image_cropper: thumbnail_url_options[:crop]
              }) do
              concat tag.button(
                render_icon("close"),
                type: "button",
                class: "picture_tool delete"
              )
              concat(
                tag.div(class: "picture_image") do
                  render Alchemy::Admin::PictureThumbnail.new(
                    ingredient,
                    css_class: "img_paddingtop",
                    placeholder: render_icon(:image, size: "xl")
                  )
                end
              )
              if css_class.present?
                concat render(
                  "alchemy/ingredients/shared/picture_css_class",
                  css_class: css_class
                )
              end
              concat(
                tag.div(class: "edit_images_bottom") do
                  render(
                    "alchemy/ingredients/shared/picture_tools",
                    picture_editor: self
                  )
                end
              )
            end
          )
          concat hidden_field_tag(form_field_name(:picture_id),
            picture&.id,
            id: form_field_id(:picture_id),
            data: {
              picture_id: true,
              image_file_width: image_file_width,
              image_file_height: image_file_height
            })
          concat hidden_field_tag(form_field_name(:link), ingredient.link, data: {link_value: true}, id: nil)
          concat hidden_field_tag(form_field_name(:link_title), ingredient.link_title, data: {link_title: true}, id: nil)
          concat hidden_field_tag(form_field_name(:link_class_name), ingredient.link_class_name, data: {link_class: true}, id: nil)
          concat hidden_field_tag(form_field_name(:link_target), ingredient.link_target, data: {link_target: true}, id: nil)
          concat hidden_field_tag(form_field_name(:crop_from), ingredient.crop_from, data: {crop_from: true}, id: form_field_id(:crop_from))
          concat hidden_field_tag(form_field_name(:crop_size), ingredient.crop_size, data: {crop_size: true}, id: form_field_id(:crop_size))
        end
      end

      private

      def ingredient_label(*)
        super(:picture_id)
      end
    end
  end
end
