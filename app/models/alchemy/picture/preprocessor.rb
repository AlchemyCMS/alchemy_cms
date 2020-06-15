# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Preprocessor
      def initialize(image_file)
        @image_file = image_file
      end

      # Preprocess images after upload
      #
      # Define preprocessing options in the Alchemy::Config
      #
      #   preprocess_image_resize [String] - Downsizing example: '1000x1000>'
      #
      def call
        max_image_size = Alchemy::Config.get(:preprocess_image_resize)
        image_file.thumb!(max_image_size) if max_image_size.present?
      end

      private

      attr_reader :image_file
    end
  end
end
