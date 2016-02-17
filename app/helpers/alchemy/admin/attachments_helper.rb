module Alchemy
  module Admin
    module AttachmentsHelper
      include Alchemy::Admin::BaseHelper

      def mime_to_human(mime)
        Alchemy.t(mime, scope: 'mime_types', default: Alchemy.t(:document))
      end
    end
  end
end
