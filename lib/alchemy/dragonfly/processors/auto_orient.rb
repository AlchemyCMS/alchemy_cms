# frozen_string_literal: true

require "dragonfly/image_magick/commands"

module Alchemy
  module Dragonfly
    module Processors
      class AutoOrient
        def call(content)
          ::Dragonfly::ImageMagick::Commands.convert(
            content,
            "-auto-orient"
          )
        end
      end
    end
  end
end
