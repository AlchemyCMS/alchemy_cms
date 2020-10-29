# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    module Calculations
      # An Image smaller than dimensions
      # can not be cropped to given size - unless upsample is true.
      #
      def can_be_cropped_to?(string, upsample = false)
        return true if upsample

        is_bigger_than? sizes_from_string(string)
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

      # Given a string with an x, this function returns a Hash with point
      # :width and :height.
      #
      def sizes_from_string(string = "0x0")
        string = "0x0" if string.nil? || string.empty?

        raise ArgumentError unless string =~ /(\d*x\d*)/

        width, height = string.scan(/(\d*)x(\d*)/)[0].map(&:to_i)

        width = 0 if width.nil?
        height = 0 if height.nil?
        {
          width: width,
          height: height,
        }
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
          y: y,
        }
      end

      # Returns the aspect ratio width / height from size hash
      #
      def size_aspect_ratio(size)
        (size[:width].to_f / size[:height]).round(5)
      end

      # This function returns the :width and :height of the image file
      # as a Hash
      def image_size
        {
          width: image_file_width,
          height: image_file_height,
        }
      end

      # Round to whole pixels
      #
      def round_dimensions(dim)
        dim.each{ |key, val| dim[key] = val.round }
      end

      # Use picture gravity to adjust the cropped area so that it fits the requested size aspect ratio.
      #
      def adjust_crop_area_to_aspect_ratio(crop_from, crop_size, size_ar, crop_ar, gravity)
        old_crop_size = crop_size.clone
        case gravity[:size]
        when "shrink"
          crop_size = shrink_crop_area(crop_size, size_ar, crop_ar)
        when "closest_fit"
          crop_size = grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity, true)
        when "grow"
          crop_size = grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity)
        end

        crop_from = crop_from_after_crop_area_resize(crop_from, crop_size, old_crop_size, gravity)

        [crop_from, crop_size]
      end

      # Shrink crop area to fit requested size aspect ratio
      #
      def shrink_crop_area(crop_size, size_ar, crop_ar)
        if crop_ar < size_ar # Crop is taller than size => shrink y
          crop_size[:height] = crop_size[:height] * (crop_ar / size_ar)
        else # Crop is wider than size => shrink x
          crop_size[:width] = (crop_size[:width] * (size_ar / crop_ar))
        end

        round_dimensions(crop_size)
      end

      # Attempt to grow crop area to fit requested size aspect ratio.
      # This may not be possible due to the original images finite boundaries.
      # Then this function will actually shrink the crop area instead.
      #
      def grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity, closest_fit = false)
        max_growth = max_crop_area_growth(crop_from, crop_size)
        wanted_growth = wanted_crop_area_growth(crop_size, size_ar, crop_ar, gravity, closest_fit)
        growth = actual_crop_area_growth(wanted_growth, max_growth)

        if crop_ar < size_ar # Horizontal growth
          crop_size[:width] += growth[:left] + growth[:right]
          crop_size[:height] = crop_size[:width] / size_ar
        else # Vertical growth
          crop_size[:height] += growth[:top] + growth[:bottom]
          crop_size[:width] = crop_size[:height] * size_ar
        end

        round_dimensions(crop_size)
      end

      # Returns the new crop_from position based on crop gravity after the cropped area has been resized
      #
      def crop_from_after_crop_area_resize(crop_from, crop_size, old_crop_size, gravity)
        if old_crop_size[:height] != crop_size[:height]
          case gravity[:y]
          # No adjustment when top
          when "center"
            crop_from[:y] += (old_crop_size[:height] - crop_size[:height]) / 2
          when "bottom"
            crop_from[:y] += (old_crop_size[:height] - crop_size[:height])
          end
        end

        if old_crop_size[:width] != crop_size[:width]
          case gravity[:x]
          # No adjustment when left
          when "center"
            crop_from[:x] += (old_crop_size[:width] - crop_size[:width]) / 2
          when "right"
            crop_from[:x] += (old_crop_size[:width] - crop_size[:width])
          end
        end

        crop_from
      end

      # Returns the maximum no of pixels the cropping area can grow in each direction
      # based on the size of the original image.
      #
      def max_crop_area_growth(crop_from, crop_size)
        {
          top: crop_from[:y],
          right: image_size[:width] - crop_from[:x] - crop_size[:width],
          bottom: image_size[:height] - crop_from[:y] - crop_size[:height],
          left: crop_from[:x],
        }
      end

      # Returns the amount of pixels we "would like" the cropping area to grow in each direction
      # in order to fit requested size aspect ratio.
      # Not yet taking the original images finite size into account.
      #
      def wanted_crop_area_growth(crop_size, size_ar, crop_ar, gravity, closest_fit = false)
        growth = { top: 0, right: 0, bottom: 0, left: 0 }

        if crop_ar < size_ar # Crop is taller than size => grow x
          new_width = (crop_size[:width] * size_ar / crop_ar)
          case gravity[:x]
          when "left"
            growth[:right] = new_width - crop_size[:width]
          when "center"
            growth[:left] = (new_width - crop_size[:width]) / 2
            growth[:right] = growth[:left]
          when "right"
            growth[:left] = new_width - crop_size[:width]
          end
        else # Crop is wider than size => grow y
          new_height = (crop_size[:height] * crop_ar / size_ar)
          case gravity[:y]
          when "top"
            growth[:bottom] = new_height - crop_size[:height]
          when "center"
            growth[:top] = (new_height - crop_size[:height]) / 2
            growth[:bottom] = growth[:top]
          when "bottom"
            growth[:top] = new_height - crop_size[:height]
          end
        end

        # Halve growth for closest fit
        # This will apply some shrinking in other direction when aspect ratio is re-established
        if closest_fit
          growth.each do |direction, value|
            growth[direction] = value.to_f / 2
          end
        end

        growth
      end

      # This function gets the actual growth values by comparing the wanted_crop_area_growth
      # against what is possible within the original images boundaries (max_crop_area_growth)
      #
      # The most limited of the non zero wanted growth values will be the upper limit for all directions.
      # As there will only be more than 1 growth direction when centering and to maintain center
      # both (opposite) growth directions have to be equal
      #
      def actual_crop_area_growth(wanted_growth, max_growth)
        possible_growth = {} # Will only contain non zero wanted growth directions
        wanted_growth.reject{ |_d, v| v.zero? }.each do |direction, _value|
          possible_growth[direction] = if wanted_growth[direction] <= max_growth[direction]
            wanted_growth[direction]
          else
            max_growth[direction]
          end
        end

        max_growth_any_direction = possible_growth.values.min || 0

        actual_growth = {}
        wanted_growth.keys.each do |direction|
          actual_growth[direction] = possible_growth[direction] ? max_growth_any_direction : 0
        end

        actual_growth
      end
    end
  end
end
