module Alchemy
  class StorePictureThumbJob < BaseJob
    queue_as :default

    def perform(thumb, uid, options = {})
      picture = thumb.picture
      variant = PictureVariant.new(picture, options)
      begin
        PictureThumb.storage_class.call(variant, uid)
      rescue => e
        ErrorTracking.notification_handler.call(e)
        # destroy the thumb if processing or storing fails
        thumb.destroy
      end
    end
  end
end
