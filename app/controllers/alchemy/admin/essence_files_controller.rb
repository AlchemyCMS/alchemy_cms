# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceFilesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceFile

      before_action :load_essence_file, only: [:edit, :update]

      helper "Alchemy::Admin::Contents"

      def edit
        @content = @essence_file.content
      end

      def update
        @essence_file.update(essence_file_params)
      end

      # Assigns file, but does not saves it.
      #
      # When the user saves the element the content gets updated as well.
      #
      def assign
        @content = Content.find_by(id: params[:content_id])
        @attachment = Attachment.find_by(id: params[:attachment_id])
        @content.essence.attachment = @attachment

        # We need to update timestamp here because we don't save yet,
        # but the cache needs to be get invalid.
        @content.touch
      end

      private

      def essence_file_params
        params.require(:essence_file).permit(:title, :css_class, :link_text)
      end

      def load_essence_file
        @essence_file = EssenceFile.find(params[:id])
      end
    end
  end
end
