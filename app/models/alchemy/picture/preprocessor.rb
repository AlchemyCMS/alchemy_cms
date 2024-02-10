# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Preprocessor
      def initialize(attachable)
        @attachable = attachable
      end

      # Preprocess images after upload
      #
      # Define preprocessing options in the Alchemy::Config
      #
      #   preprocess_image_resize [String] - Downsizing example: '1000x1000>'
      #
      def call
        max_image_size = Alchemy::Config.get(:preprocess_image_resize)
        if max_image_size.present?
          self.class.process_thumb(attachable, size: max_image_size)
        end
      end

      attr_reader :attachable

      class << self
        def self.generate_thumbs!(attachable)
          Alchemy::Picture::THUMBNAIL_SIZES.values.each do |size|
            process_thumb(attachable, size: size, flatten: true)
          end
        end

        private

        def process_thumb(attachable, options = {})
          attachable.variant :thumb,
            Alchemy::DragonflyToImageProcessing.call(options),
            preprocessed: true
        end
      end
    end
  end
end
