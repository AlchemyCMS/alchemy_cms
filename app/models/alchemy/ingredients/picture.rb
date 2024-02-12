# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A picture assignment
    #
    # Assign Alchemy::Picture to this ingredient
    #
    # Optionally you can add a link
    # As well as set the alt tag, a caption and title
    #
    class Picture < Alchemy::Ingredient
      include Alchemy::PictureThumbnails

      store_accessor :data,
        :alt_tag,
        :caption,
        :crop_from,
        :crop_size,
        :css_class,
        :link_class_name,
        :link_target,
        :link_title,
        :link,
        :render_size,
        :title

      related_object_alias :picture, class_name: "Alchemy::Picture"

      allow_settings %i[
        crop
        css_classes
        fixed_ratio
        linkable
        size
        sizes
        srcset
        upsample
      ]

      def alt_text
        alt_tag.presence || picture&.description || picture&.name&.humanize
      end

      # The first 30 characters of the pictures name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        picture&.name.to_s[0..max_length - 1]
      end

      # The picture view component with mapped options.
      #
      # @param options [Hash] - Passed to the view component
      # @param html_options [Hash] - Passed to the view component
      #
      # @return Alchemy::Ingredients::PictureView
      def as_view_component(options: {}, html_options: {})
        PictureView.new(
          self,
          show_caption: options.delete(:show_caption),
          disable_link: options.delete(:disable_link),
          srcset: options.delete(:srcset),
          sizes: options.delete(:sizes),
          picture_options: options,
          html_options: html_options
        )
      end
    end
  end
end
