# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceVideosController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceVideo
      before_action :load_essence

      def update
        @essence_video.update(essence_video_params)
      end

      private

      def load_essence
        @essence_video = EssenceVideo.find(params[:id])
      end

      def essence_video_params
        params.require(:essence_video).permit(
          :width,
          :height,
          :autoplay,
          :controls,
          :loop,
          :muted,
          :preload,
          :attachment_id
        )
      end
    end
  end
end
