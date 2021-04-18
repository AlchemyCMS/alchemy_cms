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
