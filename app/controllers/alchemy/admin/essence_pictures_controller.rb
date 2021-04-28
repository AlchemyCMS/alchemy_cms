# frozen_string_literal: true

module Alchemy
  module Admin
    class EssencePicturesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssencePicture

      before_action :load_essence_picture, only: [:edit, :crop, :update]
      before_action :load_content, only: [:edit, :update]

      helper "alchemy/admin/contents"
      helper "alchemy/admin/essences"
      helper "alchemy/url"

      def edit
      end

      def crop
        @picture = Picture.find_by(id: params[:picture_id])
        if @picture
          @essence_picture.picture = @picture
          @settings = @essence_picture.image_cropper_settings
        else
          @no_image_notice = Alchemy.t(:no_image_for_cropper_found)
        end
      end

      def update
        @essence_picture.update(essence_picture_params)
      end

      private

      def load_essence_picture
        @essence_picture = EssencePicture.find(params[:id])
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
