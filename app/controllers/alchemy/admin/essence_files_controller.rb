module Alchemy
  module Admin
    class EssenceFilesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceFile

      helper "Alchemy::Admin::Contents"

      def edit
        @content = Content.find(params[:id])
        @options = options_from_params
        @essence_file = @content.essence
      end

      def update
        @essence_file = EssenceFile.find(params[:id])
        @essence_file.update_attributes(params[:essence_file])
      end

      def assign
        @content = Content.find_by(id: params[:content_id])
        @attachment = Attachment.find_by(id: params[:attachment_id])
        @content.essence.attachment = @attachment
        @options = options_from_params
      end

    end
  end
end
