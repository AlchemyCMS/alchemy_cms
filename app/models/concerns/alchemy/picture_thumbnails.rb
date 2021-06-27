# frozen_string_literal: true

module Alchemy
  # Picture thumbnails and cropping concerns
  module PictureThumbnails
    extend ActiveSupport::Concern

    included do
      before_save :fix_crop_values

      delegate :image_file_width, :image_file_height, :image_file, to: :picture, allow_nil: true
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
    #   essence_picture.picture_url(size: '200x300', crop: true, format: 'gif')
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

      crop = !!settings[:crop]

      {
        format: picture.default_render_format,
        crop: crop,
        crop_from: crop && crop_from.presence || nil,
        crop_size: crop && crop_size.presence || nil,
        size: settings[:size],
      }.with_indifferent_access
    end

    # Returns an url for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [String]
    def thumbnail_url
      return if picture.nil?

      picture.url(thumbnail_url_options) || "alchemy/missing-image.svg"
    end

    # Thumbnail rendering options
    #
    # @return [HashWithIndifferentAccess]
    def thumbnail_url_options
      crop = !!settings[:crop]

      {
        size: "160x120",
        crop: crop,
        crop_from: crop && crop_from.presence || default_crop_from&.join("x"),
        crop_size: crop && crop_size.presence || default_crop_size&.join("x"),
        flatten: true,
        format: picture&.image_file_format || "jpg",
      }
    end

    # Settings for the graphical JS image cropper
    def image_cropper_settings
      Alchemy::ImageCropperSettings.new(
        render_size: dimensions_from_string(render_size.presence || settings[:size]),
        default_crop_from: default_crop_from,
        default_crop_size: default_crop_size,
        fixed_ratio: settings[:fixed_ratio],
        image_width: picture&.image_file_width,
        image_height: picture&.image_file_height,
      ).to_h
    end

    # Show image cropping link for content
    def allow_image_cropping?
      settings[:crop] && picture &&
        picture.can_be_cropped_to?(
          settings[:size],
          settings[:upsample],
        ) && !!picture.image_file
    end

    private

    def default_crop_size
      return nil unless settings[:crop] && settings[:size]

      mask = inferred_dimensions_from_string(settings[:size])
      zoom = thumbnail_zoom_factor(mask)
      return nil if zoom.zero?

      [(mask[0] / zoom), (mask[1] / zoom)].map(&:round)
    end

    def thumbnail_zoom_factor(mask)
      [
        mask[0].to_f / (image_file_width || 1),
        mask[1].to_f / (image_file_height || 1),
      ].max
    end

    def default_crop_from
      return nil unless settings[:crop]
      return nil if default_crop_size.nil?

      [
        ((image_file_width || 0) - default_crop_size[0]) / 2,
        ((image_file_height || 0) - default_crop_size[1]) / 2,
      ].map(&:round)
    end

    def dimensions_from_string(string)
      return if string.nil?

      string.split("x", 2).map(&:to_i)
    end

    def inferred_dimensions_from_string(string)
      return if string.nil?

      width, height = dimensions_from_string(string)
      ratio = image_file_width.to_f / image_file_height.to_i

      if width.zero? && ratio.is_a?(Float)
        width = height * ratio
      end

      if height.zero? && ratio.is_a?(Float)
        height = width / ratio
      end

      [width.to_i, height.to_i]
    end

    def fix_crop_values
      %i[crop_from crop_size].each do |crop_value|
        if public_send(crop_value).is_a?(String)
          public_send("#{crop_value}=", normalize_crop_value(crop_value))
        end
      end
    end

    def normalize_crop_value(crop_value)
      public_send(crop_value).split("x").map { |n| normalize_number(n) }.join("x")
    end

    def normalize_number(number)
      number = number.to_f.round
      number.negative? ? 0 : number
    end
  end
end
