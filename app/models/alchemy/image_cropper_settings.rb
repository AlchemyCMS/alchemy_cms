# frozen_string_literal: true

module Alchemy
  # Settings for the graphical JS image cropper
  class ImageCropperSettings
    attr_reader :render_size, :default_crop_from, :default_crop_size, :fixed_ratio, :image_width, :image_height

    def initialize(render_size:, default_crop_from:, default_crop_size:, fixed_ratio:, image_width:, image_height:)
      @render_size = render_size || [0, 0]
      @fixed_ratio = fixed_ratio
      @image_width = image_width.to_i
      @image_height = image_height.to_i
      @default_crop_from = default_crop_from || [0, 0]
      @default_crop_size = default_crop_size || [@image_width, @image_height]
    end

    def to_h
      return {} if image_width.zero? || image_height.zero?

      {
        min_size: large_enough? ? min_size : false,
        ratio: ratio,
        default_box: default_box,
        image_size: [image_width, image_height],
      }.freeze
    end

    def [](key)
      to_h[key]
    end

    private

    def ratio
      return false if fixed_ratio == false
      return ratio_from_size if fixed_ratio.nil?

      Float(fixed_ratio)
    end

    # Only returns an array of width and height if image is large enough
    # or false to disable min size option of the image cropper
    def large_enough?
      return true if render_size.any?(&:zero?)

      image_width >= render_size[0] && image_height >= render_size[1]
    end

    # Infers the aspect ratio from size or fixed_ratio. If you don't want a fixed
    # aspect ratio, don't specify a size or only width or height.
    #
    def ratio_from_size
      if render_size.none?(&:zero?)
        render_size[0].to_f / render_size[1]
      elsif [image_width, image_height].none?(&:zero?)
        image_width.to_f / image_height
      else
        false
      end
    end

    # Infers the minimum width or height
    # if the aspect ratio and one dimension is specified.
    #
    def min_size
      return render_size unless ratio

      if render_size[1].zero?
        [render_size[0], (render_size[0] / ratio).to_i]
      else
        [(render_size[1] * ratio).to_i, render_size[1]]
      end
    end

    # Given a point and a mask, this function returns the area on the
    # underlying canvas as a Hash of two points
    #
    def default_box
      [
        default_crop_from[0],
        default_crop_from[1],
        default_crop_from[0] + default_crop_size[0],
        default_crop_from[1] + default_crop_size[1],
      ]
    end
  end
end
