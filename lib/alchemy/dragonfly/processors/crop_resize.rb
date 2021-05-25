# frozen_string_literal: true

require "dragonfly/image_magick/commands"

module Alchemy
  module Dragonfly
    module Processors
      class CropResize
        include ::Dragonfly::ParamValidators

        IS_CROP_ARGUMENT = ->(args_string) {
          args_string.match?(::Dragonfly::ImageMagick::Processors::Thumb::CROP_GEOMETRY)
        }

        IS_RESIZE_ARGUMENT = ->(args_string) {
          args_string.match?(::Dragonfly::ImageMagick::Processors::Thumb::RESIZE_GEOMETRY)
        }

        def call(content, crop_argument, resize_argument)
          validate!(crop_argument, &IS_CROP_ARGUMENT)
          validate!(resize_argument, &IS_RESIZE_ARGUMENT)
          ::Dragonfly::ImageMagick::Commands.convert(
            content,
            "-crop #{crop_argument} -resize #{resize_argument}"
          )
        end

        def update_url(attrs, _args = "", opts = {})
          format = opts["format"]
          attrs.ext = format if format
        end
      end
    end
  end
end
