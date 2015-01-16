module Alchemy
  module Admin
    class EssenceFilesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceFile

      before_filter :load_essence_file, only: [:edit, :update]

      helper "Alchemy::Admin::Contents"

      def edit
        @content = @essence_file.content
        @options = options_from_params
      end

      def update
        @essence_file.update(essence_file_params)
      end

      def assign
        @content = Content.find_by(id: params[:content_id])
        @attachment = Attachment.find_by(id: params[:attachment_id])
        @content.essence.attachment = @attachment
        @options = options_from_params
      end

      private

      def essence_file_params
        params.require(:essence_file).permit(:title, :css_class)
      end

      def load_essence_file
        @essence_file = EssenceFile.find(params[:id])
      end
    end
  end
end
