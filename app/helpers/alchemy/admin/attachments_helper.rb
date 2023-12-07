# frozen_string_literal: true

module Alchemy
  module Admin
    module AttachmentsHelper
      include Alchemy::Admin::BaseHelper
      include Alchemy::Filetypes

      def mime_to_human(mime)
        Alchemy.t(mime, scope: "mime_types", default: Alchemy.t(:document))
      end

      def attachment_preview_size(attachment)
        case attachment.file_mime_type
        when *IMAGE_FILE_TYPES then "600x475"
        when *AUDIO_FILE_TYPES then "600x190"
        when *VIDEO_FILE_TYPES then "600x485"
        when "application/pdf" then "600x600"
        else
          "600x145"
        end
      end
    end
  end
end
