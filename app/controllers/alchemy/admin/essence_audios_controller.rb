module Alchemy
  module Admin
    class EssenceAudiosController < Alchemy::Admin::BaseController

      def update
        @essence_audio = EssenceAudio.find(params[:id])
        @essence_audio.update_attributes(params[:essence_audio])
      end

    end
  end
end
