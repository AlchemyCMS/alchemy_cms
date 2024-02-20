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
          # create the thumb before storing to be able to background the storage job
          Alchemy::PictureThumb.create_or_find_by!(signature: signature) do |thumb|
            thumb.picture = variant.picture
            thumb.uid = uid
          end.tap do |thumb|
            Alchemy::StorePictureThumbJob.perform_later(thumb, uid, variant.options)
          end
        end
      end
    end
  end
end
