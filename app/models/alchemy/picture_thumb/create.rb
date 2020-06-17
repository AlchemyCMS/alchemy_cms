# frozen_string_literal: true

module Alchemy
  class PictureThumb < BaseRecord
    # Stores the render result of a Alchemy::PictureVariant
    # in the configured Dragonfly datastore
    # (Default: Dragonfly::FileDataStore)
    #
    class Create
      class << self
        # @param [Alchemy::PictureVariant] variant the to be rendered image
        # @param [String] signature A unique hashed version of the rendering options
        # @param [String] uid The Unique Image Identifier the image is stored at
        #
        # @return [Alchemy::PictureThumb] The persisted thumbnail record
        #
        def call(variant, signature, uid)
          image = variant.image
          image.to_file(server_path(uid)).close
          variant.picture.thumbs.create!(
            picture: variant.picture,
            signature: signature,
            uid: uid,
          )
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
