# frozen_string_literal: true

module Alchemy
  # This concern can extend classes that expose image_file, image_file_width and image_file_height.
  # It provides methods for cropping and resizing.
  #
  module Picture::Transformations
    extend ActiveSupport::Concern

    included do
      include Alchemy::Picture::Calculations
      include Alchemy::Picture::RenderCrop
    end

    THUMBNAIL_WIDTH = 160
    THUMBNAIL_HEIGHT = 120

    # Returns the default centered image mask for a given size.
    # If the mask is bigger than the image, the mask is scaled down
    # so the largest possible part of the image is visible.
    #
    def default_mask(mask_arg, to_points = true)
      mask = mask_arg.dup
      mask[:width] = image_file_width if mask[:width].zero?
      mask[:height] = image_file_height if mask[:height].zero?

      crop_size = size_when_fitting({width: image_file_width, height: image_file_height}, mask)
      top_left = get_top_left_crop_corner(crop_size)

      to_points ? point_and_mask_to_points(top_left, crop_size) : [top_left, crop_size]
    end

    # Returns a size value String for the thumbnail used in essence picture editors.
    #
    def thumbnail_size(size_string = "0x0", crop = false)
      size = sizes_from_string(size_string)

      # only if crop is set do we need to actually parse the size string, otherwise
      # we take the base image size.
      if crop
        size[:width] = get_base_dimensions[:width] if size[:width].zero?
        size[:height] = get_base_dimensions[:height] if size[:height].zero?
        size = reduce_to_image(size)
      else
        size = get_base_dimensions
      end

      size = size_when_fitting({width: THUMBNAIL_WIDTH, height: THUMBNAIL_HEIGHT}, size)
      "#{size[:width]}x#{size[:height]}"
    end

    # Returns the rendered cropped image.
    # "size" is the requested size from settings or render
    # "render_size" comes from a sizes selection in Picture properties, stored in db.
    # "render_crop" boolean states if size will crop to fit aspect ratio.
    # This could lead to a secondary cropping if crop=true and the user had already cropped the image in admin.
    # See render_crop.rb for more information
    #
    def crop(size, render_size, crop_from = nil, crop_size = nil, render_crop = false, gravity = {}, upsample = false)
      raise "No size given!" if size.empty?

      render_to = sizes_from_string(size)

      top_left, crop_dimensions = get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

      xy_crop_resize(render_to, top_left, crop_dimensions, upsample)
    end

    # Get crop_from position and crop_size dimensions in correct hash formats
    #
    # 1. Check if the image has been cropped => has crop_from, crop_size
    # 2. If not, check if a default cropping mask is applied
    # 3. If requested size aspect ratio differs from the cropped area => Adjust cropping area first
    #
    def get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)
      size = sizes_from_string(size)
      render_size = sizes_from_string(render_size) if render_size.present?

      if crop_from.present? && crop_size.present? # User has cropped image
        crop_from = point_from_string(crop_from)
        crop_size = sizes_from_string(crop_size)
      elsif render_size.present? # User has selected a size in picture properties, essence_pictures/edit.html.erb
        crop_from, crop_size = default_mask(render_size, false)
      else # Size specified in content settings/render options
        crop_from, crop_size = default_mask(size, false)
      end

      # If render crop requested and aspect ratio changed => adjust cropping
      if render_crop && gravity.present? && aspect_ratio(size) != aspect_ratio(crop_size)
        crop_from, crop_size = adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)
      end

      [crop_from, crop_size]
    end

    # Returns the rendered resized image using imagemagick directly.
    #
    def resize(size, upsample = false)
      image_file.thumb(upsample ? size : "#{size}>")
    end

    # Returns true if picture's width is greater than it's height
    #
    def landscape_format?
      image_file.landscape?
    end
    alias_method :landscape?, :landscape_format?

    # Returns true if picture's width is smaller than it's height
    #
    def portrait_format?
      image_file.portrait?
    end
    alias_method :portrait?, :portrait_format?

    # Returns true if picture's width and height is equal
    #
    def square_format?
      image_file.aspect_ratio == 1.0
    end
    alias_method :square?, :square_format?

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
        y: y,
      }
    end

    # Given dimensions for a possibly destructive crop operation,
    # this function returns the top left corner as a Hash
    # with keys :x, :y
    #
    def get_top_left_crop_corner(dimensions)
      {
        x: (image_file_width - dimensions[:width]) / 2,
        y: (image_file_height - dimensions[:height]) / 2,
      }
    end

    # Gets the base dimensions (the dimensions of the Picture before scaling).
    # If anything is missing, it gets padded with zero (Integer 0).
    # This is the order of precedence: crop_size > image_size
    def get_base_dimensions
      if crop_size?
        sizes_from_string(crop_size)
      else
        image_size
      end
    end

    # This function takes a target and a base dimensions hash and returns
    # the dimensions of the image when the base dimensions hash fills
    # the target.
    #
    # Aspect ratio will be preserved.
    #
    def size_when_fitting(target, dimensions = get_base_dimensions)
      zoom = [
        dimensions[:width].to_f / target[:width],
        dimensions[:height].to_f / target[:height],
      ].max

      if zoom == 0.0
        width = target[:width]
        height = target[:height]
      else
        width = (dimensions[:width] / zoom).round
        height = (dimensions[:height] / zoom).round
      end

      {width: width.to_i, height: height.to_i}
    end

    # Given a point as a Hash with :x and :y, and a mask with
    # :width and :height, this function returns the area on the
    # underlying canvas as a Hash of two points
    #
    def point_and_mask_to_points(point, mask)
      {
        x1: point[:x],
        y1: point[:y],
        x2: point[:x] + mask[:width],
        y2: point[:y] + mask[:height],
      }
    end

    # Converts a dimensions hash to a string of from "20x20"
    #
    def dimensions_to_string(dimensions)
      "#{dimensions[:width]}x#{dimensions[:height]}"
    end

    # Use imagemagick to custom crop an image. Uses -thumbnail for better performance when resizing.
    #
    def xy_crop_resize(dimensions, top_left, crop_dimensions, upsample)
      crop_argument = ""

      # Only crop if dimensions changed
      if crop_dimensions[:width] != image_file_width || crop_dimensions[:height] != image_file_height
        crop_argument += "-crop #{dimensions_to_string(crop_dimensions)}"
        crop_argument += "+#{top_left[:x]}+#{top_left[:y]} "
      end

      resize_argument = "-resize #{dimensions_to_string(dimensions)}"
      resize_argument += ">" unless upsample
      image_file.convert "#{crop_argument}#{resize_argument}"
    end

    # Used when centercropping.
    #
    def reduce_to_image(dimensions)
      {
        width: [dimensions[:width], image_file_width].min,
        height: [dimensions[:height], image_file_height].min,
      }
    end
  end
end
