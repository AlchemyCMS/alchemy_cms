module Alchemy
  module Admin
    class EssenceVideosController < Alchemy::Admin::BaseController

      def update
        @essence_video = EssenceVideo.find(params[:id])
        @essence_video.update_attributes(params[:essence_video], :as => current_user.role.to_sym)
      end

    end
  end
end
