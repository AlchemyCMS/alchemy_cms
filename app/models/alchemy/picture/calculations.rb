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
      def sizes_from_string(string)
        width, height = string.to_s.split("x", 2).map(&:to_i)

        {
          width: width,
          height: height,
        }
      end

      # This function returns the :width and :height of the image file
      # as a Hash
      def image_size
        {
          width: image_file_width,
          height: image_file_height,
        }
      end
    end
  end
end
