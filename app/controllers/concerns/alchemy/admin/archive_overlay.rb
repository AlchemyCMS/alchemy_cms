module Alchemy
  module Admin
    module ArchiveOverlay
      private

      def in_overlay?
        params[:content_id].present?
      end

      def archive_overlay
        @content = Content.find_by(id: params[:content_id])

        respond_to do |format|
          format.html { render partial: 'archive_overlay' }
          format.js   { render action:  'archive_overlay' }
        end
      end
    end
  end
end
