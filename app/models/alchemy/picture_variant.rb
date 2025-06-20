# frozen_string_literal: true

require "forwardable"

module Alchemy
  # Represents a rendered picture
  #
  # Resizes, crops and encodes the image with imagemagick
  #
  class PictureVariant
    extend Forwardable

    include Alchemy::Logger

    ANIMATED_IMAGE_FORMATS = %w[gif webp]
    TRANSPARENT_IMAGE_FORMATS = %w[gif webp png]
    ENCODABLE_IMAGE_FORMATS = %w[jpg jpeg webp]

    attr_reader :picture, :render_format

    def_delegators :@picture,
      :image_file,
      :image_file_width,
      :image_file_height,
      :image_file_name,
      :image_file_size

    # @param [Alchemy::Picture]
    #
    # @param [Hash] options passed to the image processor
    # @option options [Boolean] :crop Pass true to enable cropping
    # @option options [String] :crop_from Coordinates to start cropping from
    # @option options [String] :crop_size Size of the cropping area
    # @option options [Boolean] :flatten Pass true to flatten GIFs
    # @option options [String|Symbol] :format Image format to encode the image in
    # @option options [Integer] :quality JPEG compress quality
    # @option options [String] :size Size of resulting image in WxH
    # @option options [Boolean] :upsample Pass true to upsample (grow) an image if the original size is lower than the resulting size
    #
    def initialize(picture, options = {})
      raise ArgumentError, "Picture missing!" if picture.nil?

      @picture = picture
      @options = options
      @render_format = (options[:format] || picture.default_render_format).to_s
    end

    # Process a variant of picture
    #
    # @return [Dragonfly::Attachment|Dragonfly::Job] The processed image variant
    #
    def image
      image = image_file

      raise MissingImageFileError, "Missing image file for #{picture.inspect}" if image.nil?

      image = processed_image(image, @options)
      encoded_image(image, @options)
    rescue MissingImageFileError, WrongImageFormatError => e
      log_warning(e.message)
      nil
    end

    private

    # Returns the processed image dependent of size and cropping parameters
    def processed_image(image, options = {})
      size = options[:size]
      upsample = !!options[:upsample]

      return image unless size.present? && picture.has_convertible_format?

      if options[:crop]
        crop(size, options[:crop_from], options[:crop_size], upsample)
      else
        resize(size, upsample)
      end
    end

    # Returns the encoded image
    #
    # Flatten animated gifs, only if converting to a different format.
    # Can be overwritten via +options[:flatten]+.
    #
    def encoded_image(image, options = {})
      unless render_format.in?(Alchemy::Picture.allowed_filetypes)
        raise WrongImageFormatError.new(picture, @render_format)
      end

      options = {
        flatten: !render_format.in?(ANIMATED_IMAGE_FORMATS) && picture.image_file_extension == "gif"
      }.with_indifferent_access.merge(options)

      encoding_options = []

      convert_format = render_format.sub("jpeg", "jpg") != picture.image_file_extension.sub("jpeg", "jpg")

      if encodable_image? && (convert_format || options[:quality])
        quality = options[:quality] || Alchemy.config.output_image_quality
        encoding_options << "-quality #{quality}"
      end

      if options[:flatten]
        if render_format.in?(TRANSPARENT_IMAGE_FORMATS) && picture.image_file_extension.in?(TRANSPARENT_IMAGE_FORMATS)
          encoding_options << "-background transparent"
        end
        encoding_options << "-flatten"
      end

      convertion_needed = convert_format || encoding_options.present?

      if picture.has_convertible_format? && convertion_needed
        image = image.encode(render_format, encoding_options.join(" "))
      end

      image
    end

    def encodable_image?
      render_format.in?(ENCODABLE_IMAGE_FORMATS)
    end

    # Returns the rendered cropped image. Tries to use the crop_from and crop_size
    # parameters. When they can't be parsed, it just crops from the center.
    #
    def crop(size, crop_from = nil, crop_size = nil, upsample = false)
      raise "No size given!" if size.empty?

      render_to = inferred_sizes_from_string(size)
      if crop_from && crop_size
        top_left = point_from_string(crop_from)
        crop_dimensions = inferred_sizes_from_string(crop_size)
        xy_crop_resize(render_to, top_left, crop_dimensions, upsample)
      else
        center_crop(render_to, upsample)
      end
    end

    # Returns the rendered resized image using imagemagick directly.
    #
    def resize(size, upsample = false)
      image_file.thumbnail(upsample ? size : "#{size}>")
    end

    # Given a string with an x, this function return a Hash with key :x and :y
    #
    def point_from_string(string = "0x0")
      string = "0x0" if string.empty?
      raise ArgumentError if !string.match(/(\d*x)|(x\d*)/)

      x, y = string.scan(/(\d*)x(\d*)/)[0].map(&:to_i)

      x = 0 if x.nil?
      y = 0 if y.nil?
      {
        x: x,
        y: y
      }
    end

    def inferred_sizes_from_string(string)
      sizes = sizes_from_string(string)
      ratio = image_file_width.to_f / image_file_height

      if sizes[:width].zero?
        sizes[:width] = (sizes[:height] * ratio).round.to_i
      end
      if sizes[:height].zero?
        sizes[:height] = (sizes[:width] / ratio).round.to_i
      end

      sizes
    end

    # Given a string with an x, this function returns a Hash with point
    # :width and :height.
    #
    def sizes_from_string(string)
      width, height = string.to_s.split("x", 2).map(&:to_i)

      {
        width: width,
        height: height
      }
    end

    # Returns true if both dimensions of the base image are bigger than the dimensions hash.
    #
    def is_bigger_than?(dimensions)
      image_file_width > dimensions[:width] && image_file_height > dimensions[:height]
    end

    # Returns true is one dimension of the base image is smaller than the dimensions hash.
    #
    def is_smaller_than?(dimensions)
      !is_bigger_than?(dimensions)
    end

    # Converts a dimensions hash to a string of from "20x20"
    #
    def dimensions_to_string(dimensions)
      "#{dimensions[:width]}x#{dimensions[:height]}"
    end

    # Uses imagemagick to make a centercropped thumbnail. Does not scale the image up.
    #
    def center_crop(dimensions, upsample)
      if is_smaller_than?(dimensions) && upsample == false
        dimensions = reduce_to_image(dimensions)
      end
      image_file.thumbnail("#{dimensions_to_string(dimensions)}#")
    end

    # Use imagemagick to custom crop an image. Uses -thumbnail for better performance when resizing.
    #
    def xy_crop_resize(dimensions, top_left, crop_dimensions, upsample)
      crop_argument = dimensions_to_string(crop_dimensions)
      crop_argument += "+#{top_left[:x]}+#{top_left[:y]}"

      resize_argument = dimensions_to_string(dimensions)
      resize_argument += ">" unless upsample
      image_file.crop_resize(crop_argument, resize_argument)
    end

    # Used when centercropping.
    #
    def reduce_to_image(dimensions)
      {
        width: [dimensions[:width].to_i, image_file_width.to_i].min,
        height: [dimensions[:height].to_i, image_file_height.to_i].min
      }
    end
  end
end
