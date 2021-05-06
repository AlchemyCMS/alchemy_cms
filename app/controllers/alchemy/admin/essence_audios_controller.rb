# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceAudiosController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceAudio
      before_action :load_essence

      def update
        @essence_audio.update(essence_audio_params)
      end

      private

      def load_essence
        @essence_audio = EssenceAudio.find(params[:id])
      end

      def essence_audio_params
        params.require(:essence_audio).permit(
          :autoplay,
          :controls,
          :loop,
          :muted,
          :attachment_id
        )
      end
    end
  end
end
