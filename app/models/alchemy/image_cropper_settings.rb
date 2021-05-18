# frozen_string_literal: true

module Alchemy
  # Settings for the graphical JS image cropper
  class ImageCropperSettings
    FLOAT_REGEX = /\A\d+(\.\d+)?\z/

    include Alchemy::Picture::Calculations

    attr_reader :render_size, :crop_from, :crop_size, :fixed_ratio, :image_width, :image_height

    def initialize(render_size:, crop_from:, crop_size:, fixed_ratio:, image_width:, image_height:)
      @render_size = sizes_from_string(render_size)
      @crop_from = crop_from
      @crop_size = crop_size
      @fixed_ratio = fixed_ratio
      @image_width = image_width
      @image_height = image_height
    end

    def to_h
      return {} unless image_width && image_height

      min_size = render_size
      ratio = ratio_from_size_or_settings(min_size)
      infer_width_or_height_from_ratio!(min_size, ratio)
      default_box = default_mask(min_size)

      {
        min_size: min_size_value(min_size),
        ratio: ratio,
        default_box: default_box.values,
        image_size: [image_width, image_height],
      }.freeze
    end

    def [](key)
      to_h[key]
    end

    private

    # Only returns an array of width and height if image is large enough
    # or false to disable min size option of the image cropper
    def min_size_value(min_size)
      if image_width >= min_size[:width] && image_height >= min_size[:height]
        min_size.values
      else
        false
      end
    end

    # Infers the aspect ratio from size or fixed_ratio. If you don't want a fixed
    # aspect ratio, don't specify a size or only width or height.
    #
    def ratio_from_size_or_settings(min_size)
      if min_size.value?(0) && fixed_ratio.to_s =~ FLOAT_REGEX
        fixed_ratio.to_f
      elsif !min_size[:width].zero? && !min_size[:height].zero?
        min_size[:width].to_f / min_size[:height]
      else
        false
      end
    end

    # Infers the minimum width or height
    # if the aspect ratio and one dimension is specified.
    #
    def infer_width_or_height_from_ratio!(min_size, ratio)
      return unless ratio

      if min_size[:height].zero?
        min_size[:height] = (min_size[:width] / ratio).to_i
      else
        min_size[:width] = (min_size[:height] * ratio).to_i
      end
    end

    # Returns the default centered image mask for a given size.
    # If the mask is bigger than the image, the mask is scaled down
    # so the largest possible part of the image is visible.
    #
    def default_mask(min_size)
      mask = min_size.dup
      mask[:width] = image_width if mask[:width].zero?
      mask[:height] = image_height if mask[:height].zero?

      crop_size = size_when_fitting({ width: image_width, height: image_height }, mask)
      top_left = get_top_left_crop_corner(crop_size)

      point_and_mask_to_points(top_left, crop_size)
    end

    # This function takes a target and a base dimensions hash and returns
    # the dimensions of the image when the base dimensions hash fills
    # the target.
    #
    # Aspect ratio will be preserved.
    #
    def size_when_fitting(target, dimensions)
      zoom = [
        dimensions[:width].to_f / target[:width],
        dimensions[:height].to_f / target[:height],
      ].max

      if zoom.zero?
        width = target[:width]
        height = target[:height]
      else
        width = (dimensions[:width] / zoom).round
        height = (dimensions[:height] / zoom).round
      end

      { width: width.to_i, height: height.to_i }
    end

    # Given dimensions for a possibly destructive crop operation,
    # this function returns the top left corner as a Hash
    # with keys :x, :y
    #
    def get_top_left_crop_corner(dimensions)
      {
        x: (image_width - dimensions[:width]) / 2,
        y: (image_height - dimensions[:height]) / 2,
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
  end
end
