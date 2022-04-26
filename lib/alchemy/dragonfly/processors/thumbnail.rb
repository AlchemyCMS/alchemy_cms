# frozen_string_literal: true

require "dragonfly/image_magick/processors/thumb"

module Alchemy
  module Dragonfly
    module Processors
      class Thumbnail < ::Dragonfly::ImageMagick::Processors::Thumb
        def call(content, geometry, opts = {})
          # store content into an instance variable to use it in args_for_geometry - method
          @content = content
          super
        end

        ##
        # due to a missing ImageMagick parameter animated GIFs were broken with the default
        # Dragonfly Thumb processor
        def args_for_geometry(geometry)
          # resize all frames in a GIF
          # @link https://imagemagick.org/script/command-line-options.php#coalesce
          # @link https://imagemagick.org/script/command-line-options.php#deconstruct
          @content&.mime_type == "image/gif" ? "-coalesce #{super} -deconstruct" : super
        end
      end
    end
  end
end
