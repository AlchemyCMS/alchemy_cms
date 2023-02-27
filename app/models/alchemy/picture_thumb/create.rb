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
          return if !variant.picture.valid?

          # create the thumb before storing
          # to prevent db race conditions
          @thumb = Alchemy::PictureThumb.create_or_find_by!(signature: signature) do |thumb|
            thumb.picture = variant.picture
            thumb.uid = uid
          end
          begin
            # process the image
            image = variant.image
            # store the processed image
            image.to_file(server_path(uid)).close
          rescue RuntimeError => e
            ErrorTracking.notification_handler.call(e)
            # destroy the thumb if processing or storing fails
            @thumb&.destroy
          end
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
