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
      ingredient_attributes(
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
        :title,
      )

      related_object_alias :picture

      # The first 30 characters of the pictures name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        picture&.name.to_s[0..max_length - 1]
      end

      # The url to show the picture.
      #
      # Takes all values like +name+ and crop sizes (+crop_from+, +crop_size+ from the build in graphical image cropper)
      # and also adds the security token.
      #
      # You typically want to set the size the picture should be resized to.
      #
      # === Example:
      #
      #   ingredient.picture_url(size: '200x300', crop: true, format: 'gif')
      #   # '/pictures/1/show/200x300/crop/cats.gif?sh=765rfghj'
      #
      # @option options size [String]
      #   The size the picture should be resized to.
      #
      # @option options format [String]
      #   The format the picture should be rendered in.
      #   Defaults to the +image_output_format+ from the +Alchemy::Config+.
      #
      # @option options crop [Boolean]
      #   If set to true the picture will be cropped to fit the size value.
      #
      # @return [String]
      def picture_url(options = {})
        return if picture.nil?

        picture.url(picture_url_options.merge(options)) || "missing-image.png"
      end

      # Picture rendering options
      #
      # Returns the +default_render_format+ of the associated +Alchemy::Picture+
      # together with the +crop_from+ and +crop_size+ values
      #
      # @return [HashWithIndifferentAccess]
      def picture_url_options
        return {} if picture.nil?

        {
          format: picture.default_render_format,
          crop_from: crop_from.presence,
          crop_size: crop_size.presence,
          size: settings[:size],
        }.with_indifferent_access
      end

      # Enable image cropping in ingredient editor
      # @return [Boolean]
      def allow_image_cropping?
        settings[:crop] && picture &&
          picture.can_be_cropped_to?(
            settings[:size],
            settings[:upsample],
          ) && !!picture.image_file
      end
    end
  end
end
