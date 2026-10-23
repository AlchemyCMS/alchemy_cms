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
    #   picture_view.picture_url(size: '200x300', crop: true, format: 'gif')
    #   # '/pictures/1/show/200x300/crop/cats.gif?sh=765rfghj'
    #
    # @option options size [String]
    #   The size the picture should be resized to.
    #
    # @option options format [String]
    #   The format the picture should be rendered in.
    #   Defaults to the +image_output_format+ from the +Alchemy.config+.
    #
    # @option options crop [Boolean]
    #   If set to true the picture will be cropped to fit the size value.
    #
    # @return [String]
    def picture_url(options = {})
      return if picture.nil?

      picture.url(picture_url_options(options)) || "missing-image.png"
    end

    # Picture rendering options
    #
    # Returns the render format of the associated +Alchemy::Picture+
    # together with the +crop_from+ and +crop_size+ values.
    #
    # The render format is taken from the +format+ option, the +format+ setting
    # of the ingredient definition or the +default_render_format+ of the picture.
    # A format is only applied if the picture can be converted.
    #
    # @param options [Hash] Options that override the defaults (i.e. +size+ or +format+ of a srcset entry)
    #
    # @return [HashWithIndifferentAccess]
    def picture_url_options(options = {})
      return {} if picture.nil?

      options = options.symbolize_keys
      crop = !!settings[:crop]

      {
        crop: crop,
        crop_from: crop && crop_from.presence || nil,
        crop_size: crop && crop_size.presence || nil,
        size: settings[:size]
      }.merge(options.except(:format)).merge(
        format: picture_render_format(options[:format] || settings[:format])
      ).with_indifferent_access
    end

    # Picture rendering options for each entry of the +srcset+ setting
    #
    # Entries can either be a size string (i.e. +"800x600"+) or a hash
    # with +size+ and optional +format+ keys.
    #
    # @param srcset [Array<String, Hash>] Defaults to the +srcset+ setting
    #
    # @return [Array<HashWithIndifferentAccess>]
    def picture_srcset_variant_options(srcset = settings.fetch(:srcset, []))
      return [] if picture.nil?

      srcset.map do |src|
        picture_url_options(src.is_a?(Hash) ? src : {size: src})
      end
    end

    # Url, dimensions and mime type for each entry of the +srcset+ setting
    #
    # === Example:
    #
    #   picture_srcset_options
    #   # => [{url: "/pictures/1/360x360/cats.webp", desc: "360w", width: "360", height: "360", type: "image/webp"}]
    #
    # @param srcset [Array<String, Hash>] Defaults to the +srcset+ setting
    #
    # @return [Array<Hash>]
    def picture_srcset_options(srcset = settings.fetch(:srcset, []))
      picture_srcset_variant_options(srcset).map do |options|
        width, height = options[:size].to_s.split("x", 2)

        {
          url: picture_url(options),
          desc: width.present? ? "#{width}w" : "#{height}h",
          width: width,
          height: height,
          type: Mime::Type.lookup_by_extension(options[:format]).to_s
        }
      end
    end

    # Returns an url for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [String]
    def thumbnail_url(size: "160x120")
      return if picture.nil?

      picture.url(thumbnail_url_options(size: size)) || "alchemy/missing-image.svg"
    end

    # Thumbnail rendering options
    #
    # @return [HashWithIndifferentAccess]
    def thumbnail_url_options(size: "160x120")
      crop = !!settings[:crop]

      {
        size: size,
        crop: crop,
        crop_from: crop && crop_from.presence || default_crop_from&.join("x"),
        crop_size: crop && crop_size.presence || default_crop_size&.join("x"),
        flatten: true,
        format: picture&.image_file_extension || "jpg"
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
        image_height: picture&.image_file_height
      ).to_h
    end

    # Show image cropping link for ingredient
    def allow_image_cropping?
      settings[:crop] && picture &&
        Alchemy.storage_adapter.image_file_present?(picture) &&
        can_be_cropped_to?
    end

    private

    def picture_render_format(format)
      if format.present? && picture.has_convertible_format?
        format.to_s
      else
        picture.default_render_format
      end
    end

    # An Image smaller than dimensions
    # can not be cropped to given size - unless upsample is true.
    #
    def can_be_cropped_to?
      return true if settings[:upsample]

      dimensions = inferred_dimensions_from_string(settings[:size])
      if dimensions
        picture.image_file_width > dimensions[0] && picture.image_file_height > dimensions[1]
      else
        false
      end
    end

    def default_crop_size
      return nil unless settings[:crop] && settings[:size]

      mask = inferred_dimensions_from_string(settings[:size])
      return if mask.nil?

      zoom = thumbnail_zoom_factor(mask)
      return nil if zoom.zero?

      [(mask[0] / zoom), (mask[1] / zoom)].map(&:round)
    end

    def thumbnail_zoom_factor(mask)
      [
        mask[0].to_f / (image_file_width || 1),
        mask[1].to_f / (image_file_height || 1)
      ].max
    end

    def default_crop_from
      return nil unless settings[:crop]
      return nil if default_crop_size.nil?

      [
        ((image_file_width || 0) - default_crop_size[0]) / 2,
        ((image_file_height || 0) - default_crop_size[1]) / 2
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

      return if ratio.nan?

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
          public_send(:"#{crop_value}=", normalize_crop_value(crop_value))
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
