# frozen_string_literal: true
module Alchemy
  module Admin
    module ArchiveOverlay
      private

      def in_overlay?
        params[:content_id].present? || params[:use_overlay]
      end

      def archive_overlay
        @content = Content.find_by(id: params[:content_id])
        @record = params[:record_type]&.constantize&.find_by(id: params[:record_id])

        respond_to do |format|
          format.html { render partial: "archive_overlay" }
          format.js   { render action:  "archive_overlay" }
        end
      end
    end
  end
end
