# frozen_string_literal: true

module Alchemy
  class PictureThumb < BaseRecord
    # Stores the render result of a Alchemy::PictureVariant
    # in the configured Dragonfly datastore
    # (Default: Dragonfly::FileDataStore)
    #
    class FileStore
      class << self
        # @param [Alchemy::PictureVariant] variant the to be rendered image
        # @param [String] uid The Unique Image Identifier the image is stored at
        #
        def call(variant, uid)
          # process the image
          image = variant.image
          # store the processed image
          image.to_file(server_path(uid)).close
        end

        private

        # Alchemys dragonfly datastore config seperates the storage path from the public server
        # path for security reasons. The Dragonfly FileDataStorage does not support that,
        # so we need to build the path on our own.
        def server_path(uid)
          dragonfly_app = ::Dragonfly.app(:alchemy_pictures)
          "#{dragonfly_app.datastore.server_root}/#{uid}"
        end
      end
    end
  end
end
