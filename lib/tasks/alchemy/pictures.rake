# frozen_string_literal: true

require "alchemy/tasks/reorient_pictures"

namespace :alchemy do
  namespace :pictures do
    # Limit any of the tasks below to a subset of pictures:
    #   rake alchemy:pictures:report PICTURE_IDS=1,2,3
    def alchemy_picture_ids
      ENV["PICTURE_IDS"]&.split(",")&.map(&:strip).presence
    end

    desc "Reports picture masters that still carry a non upright EXIF orientation (Dragonfly only)."
    task report: [:environment] do
      Alchemy::ReorientPictures.report(picture_ids: alchemy_picture_ids)
    end

    desc "Bakes the EXIF orientation into existing picture masters (Dragonfly only)."
    task reorient: [:environment] do
      Alchemy::ReorientPictures.call(picture_ids: alchemy_picture_ids)
    end
  end
end
