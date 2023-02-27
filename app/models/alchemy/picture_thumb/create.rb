# frozen_string_literal: true

module Alchemy
  class PictureThumb < BaseRecord
    # Creates a Alchemy::PictureThumb
    #
    # Stores the processes result of a Alchemy::PictureVariant
    # in the configured +Alchemy::PictureThumb.storage_class+
    # (Default: {Alchemy::PictureThumb::FileStore})
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
            Alchemy::PictureThumb.storage_class.call(variant, uid)
          rescue StandardError => e
            ErrorTracking.notification_handler.call(e)
            # destroy the thumb if processing or storing fails
            @thumb&.destroy
          end
        end
      end
    end
  end
end
