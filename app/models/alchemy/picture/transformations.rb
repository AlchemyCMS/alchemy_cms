module Alchemy
  module Picture::Transformations
    extend ActiveSupport::Concern

    #
    # This concern can extend classes that expose image_file, image_file_width and image_file_height.
    # It provides methods for cropping and resizing.
    #

    # Returns the default centered image mask for a given size.
    # If the mask is bigger than the image, the mask is scaled down
    # so the largest possible part of the image is visible.
    def default_mask(size = "0x0", upsample = false)
      raise "No size given" if size.blank?

      mask = sizes_from_string(size)

      if is_smaller_than(mask) && !upsample
        raise "This image is too small to crop"
      end

      crop_size = size_when_filling(mask)
      top_left = get_top_left_crop_corner(crop_size)

      point_and_mask_to_points(top_left, crop_size)
    end


    # Returns a size value String for the thumbnail used in essence picture editors.
    #
    def thumbnail_size(size_of_thumb = "111x93")
      dimensions_of_thumb = sizes_from_string(size_of_thumb)
      thumbnail_size = size_when_fitting(dimensions_of_thumb)

      "#{thumbnail_size[:width]}x#{thumbnail_size[:height]}"
    end

    # Returns the rendered cropped image. Tries to use the crop_from and crop_size
    # parameters. When they can't be parsed, it just crops from the center.
    #
    def crop(size, crop_from = nil, crop_size = nil, upsample = false)
      raise "No size given!" if size.empty?
      render_to = sizes_from_string(size)
      begin
        top_left = point_from_string(crop_from)
        crop_dimensions = sizes_from_string(crop_size)
        xy_crop_resize(render_to, top_left, crop_dimensions)
      rescue
        center_crop(render_to, upsample)
      end
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

    # Given a string with an x, this function returns a Hash with point
    # :width and :height
    def sizes_from_string(string = "0x0")
      string = "0x0" if string.empty?
      raise ArgumentError if !string.match(/(\d*x)|(x\d*)/)

      width, height = string.scan(/(\d*)x(\d*)/)[0].map(&:to_i)

      width = image_file_width if width.zero? || width.nil?
      height = image_file_height if height.zero? || height.nil?
      {
        width: width,
        height: height
      }
    end

    def resize(size, upsample = false)
      self.image_file.thumb(upsample ? size : "#{size}>")
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


    # Given dimensions for a possibly destructive crop operation,
    # this function returns the top left corner as a Hash
    # with keys :x, :y
    #
    def get_top_left_crop_corner(dimensions)
      {
        x: (image_file_width - dimensions[:width]) / 2,
        y: (image_file_height - dimensions[:height]) / 2
      }
    end

    def get_original_size
      if self.respond_to?(:crop_size) && !self.crop_size.nil?
        sizes_from_string(crop_size)
      else
        sizes_from_image_file
      end
    end

    # Given dimensions with :width, :height
    # this function returns dimensions which the image can fill.
    #
    def size_when_filling(dimensions)
      zoom_x = dimensions[:width].to_f / image_file_width
      zoom_y = dimensions[:height].to_f / image_file_height

      zoom = zoom_x > zoom_y ? zoom_x : zoom_y
      {
        width: (dimensions[:width] / zoom).round.to_i,
        height: (dimensions[:height] / zoom).round.to_i
      }
    end

    # Given dimensions with :width, :height
    # this function returns a dimensions in which the image can be fitted.
    #
    def size_when_fitting(dimensions)
      original_size = get_original_size
      zoom_x = dimensions[:width].to_f / original_size[:width]
      zoom_y = dimensions[:height].to_f / original_size[:height]

      zoom = zoom_x < zoom_y ? zoom_x : zoom_y
      {
        width: (original_size[:width] * zoom).round.to_i,
        height: (original_size[:height] * zoom).round.to_i
      }
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



    # This function returns the :width and :height of the image file
    # as a Hash
    def sizes_from_image_file
      {
        width: image_file_width,
        height: image_file_height
      }
    end

    def dimensions_to_string(dimensions)
      "#{dimensions[:width]}x#{dimensions[:height]}"
    end

    def is_smaller_than(dimensions)
      image_file_width < dimensions[:width] || image_file_height < dimensions[:height]
    end

    def center_crop(dimensions, upsample)
      if self.is_smaller_than(dimensions) && upsample == false
        dimensions = reduce_to_image(dimensions)
      end
      self.image_file.thumb("#{dimensions_to_string(dimensions)}#")
    end

    def xy_crop_resize(dimensions, top_left, crop_dimensions)
      crop_argument = "-crop #{dimensions_to_string(crop_dimensions)}"
      crop_argument += "+#{top_left[:x]}+#{top_left[:y]}"

      resize_argument = "-resize #{dimensions_to_string(dimensions)}"
      self.image_file.convert "#{crop_argument} #{resize_argument}"
    end

    def reduce_to_image(dimensions)
      {
        width: dimensions[:width] > image_file_width ? image_file_width : dimensions[:width],
        height: dimensions[:height] > image_file_height ? image_file_height : dimensions[:image_file_height]
      }
    end
  end
end
