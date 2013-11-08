module Alchemy
  module Admin
    module AttachmentsHelper
      include Alchemy::Admin::BaseHelper

      def mime_to_human(mime)
        I18n.t(mime, scope: 'mime_types', default: _t(:document))
      end

    end
  end
end
