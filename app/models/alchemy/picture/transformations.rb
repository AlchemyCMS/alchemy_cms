# frozen_string_literal: true

module Alchemy
  # This concern can extend classes that expose image_file, image_file_width and image_file_height.
  # It provides methods for cropping and resizing.
  #
  module Picture::Transformations
    extend ActiveSupport::Concern

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

    # Returns true if the class we're included in has a meaningful render_size attribute
    #
    def render_size?
      respond_to?(:render_size) && render_size.present?
    end

    # Returns true if the class we're included in has a meaningful crop_size attribute
    #
    def crop_size?
      respond_to?(:crop_size) && !crop_size.nil? && !crop_size.empty?
    end

    private

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
