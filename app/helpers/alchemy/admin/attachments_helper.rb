# frozen_string_literal: true

module Alchemy
  module Admin
    module AttachmentsHelper
      include Alchemy::Admin::BaseHelper

      def mime_to_human(mime)
        Alchemy.t(mime, scope: 'mime_types', default: Alchemy.t(:document))
      end

      def attachment_preview_size(attachment)
        case attachment.icon_css_class
        when 'image' then '600x475'
        when 'audio' then '600x190'
        when 'video' then '600x485'
        when 'pdf'   then '600x500'
        else
          '600x145'
        end
      end
    end
  end
end
