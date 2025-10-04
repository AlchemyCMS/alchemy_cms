module Alchemy
  class DeletePictureJob < BaseJob
    queue_as :default

    def perform(picture_id)
      picture = Alchemy::Picture.find_by(id: picture_id)
      return if picture.nil? || !picture.deletable?

      picture.destroy
    end
  end
end
