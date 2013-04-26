module Alchemy
  module Admin
    class EssenceFilesController < Alchemy::Admin::BaseController

      helper "Alchemy::Admin::Contents"

      def edit
        @content = Content.find(params[:id])
        @essence_file = @content.essence
        render layout: !request.xhr?
      end

      def update
        @essence_file = EssenceFile.find(params[:id])
        @essence_file.update_attributes(params[:essence_file])
      end

      def assign
        @content = Content.find_by_id(params[:id])
        @attachment = Attachment.find_by_id(params[:attachment_id])
        @content.essence.attachment = @attachment
        @options = params[:options] || {}
      end

    end
  end
end
