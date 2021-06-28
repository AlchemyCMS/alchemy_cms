# frozen_string_literal: true

module Alchemy
  module Admin
    class EssencePicturesController < Alchemy::Admin::BaseController
      include CropAction

      authorize_resource class: Alchemy::EssencePicture

      before_action :load_essence_picture, only: [:edit, :update]
      before_action :load_content, only: [:edit, :update]

      helper "alchemy/admin/contents"
      helper "alchemy/admin/essences"
      helper "alchemy/url"

      def edit
      end

      def update
        @essence_picture.update(essence_picture_params)
      end

      private

      def load_essence_picture
        @essence_picture = EssencePicture.find(params[:id])
      end

      def load_croppable_resource
        @croppable_resource = EssencePicture.find(params[:id])
      end

      def load_content
        @content = Content.find(params[:content_id])
      end

      def essence_picture_params
        params.require(:essence_picture).permit(:alt_tag, :caption, :css_class, :render_size, :title, :crop_from, :crop_size)
      end
    end
  end
end
