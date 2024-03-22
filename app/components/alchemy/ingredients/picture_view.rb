# frozen_string_literal: true

module Alchemy
  module Ingredients
    # Renders a picture ingredient view
    class PictureView < BaseView
      attr_reader :ingredient,
        :show_caption,
        :disable_link,
        :srcset,
        :sizes,
        :html_options,
        :picture_options,
        :picture

      # @param ingredient [Alchemy::Ingredient]
      # @param show_caption [Boolean] (true) Whether to show a caption or not, even if present on the picture.
      # @param disable_link [Boolean] (false) Whether to disable the link even if the picture has a link.
      # @param srcset [Array<String>] An array of srcset sizes that will generate variants of the picture.
      # @param sizes [Array<String>] An array of sizes that will be passed to the img tag.
      # @param picture_options [Hash] Options that will be passed to the picture url. See {Alchemy::PictureVariant} for options.
      # @param html_options [Hash] Options that will be passed to the img tag.
      # @see Alchemy::PictureVariant
      def initialize(
        ingredient,
        show_caption: nil,
        disable_link: nil,
        srcset: nil,
        sizes: nil,
        picture_options: {},
        html_options: {}
      )
        super(ingredient)
        @show_caption = settings_value(:show_caption, value: show_caption, default: true)
        @disable_link = settings_value(:disable_link, value: disable_link, default: false)
        @srcset = settings_value(:srcset, value: srcset, default: [])
        @sizes = settings_value(:sizes, value: sizes, default: [])
        @picture_options = picture_options || {}
        @html_options = html_options || {}
        @picture = ingredient.picture
      end

      def call
        return if picture.blank?

        output = caption ? img_tag + caption : img_tag

        if is_linked?
          output = link_to(output, url_for(ingredient.link), {
            title: ingredient.link_title.presence,
            target: (ingredient.link_target == "blank") ? "_blank" : nil,
            data: {link_target: ingredient.link_target.presence}
          })
        end

        if caption
          content_tag(:figure, output, {class: ingredient.css_class.presence}.merge(html_options))
        else
          output
        end.html_safe
      end

      private

      def caption
        return unless show_caption?

        @_caption ||= content_tag(:figcaption, ingredient.caption.html_safe)
      end

      def src
        ingredient.picture_url(picture_options)
      end

      def img_tag
        @_img_tag ||= image_tag(
          src, {
            alt: alt_text,
            title: ingredient.title.presence,
            class: caption ? nil : ingredient.css_class.presence,
            srcset: srcset_options.join(", ").presence,
            sizes: sizes.join(", ").presence
          }.merge(caption ? {} : html_options)
        )
      end

      def show_caption?
        show_caption && ingredient.caption.present?
      end

      def is_linked?
        !disable_link && ingredient.link.present?
      end

      def srcset_options
        srcset.map do |size|
          url = ingredient.picture_url(size: size)
          width, height = size.split("x")
          width.present? ? "#{url} #{width}w" : "#{url} #{height}h"
        end
      end

      def alt_text
        html_options.delete(:alt) || ingredient.alt_text
      end
    end
  end
end
