module Alchemy
	module Admin
		class EssenceAudiosController < Alchemy::Admin::BaseController

			def update
				@essence_audio = EssenceAudio.find(params[:id])
				@essence_audio.update_attributes(params[:essence_audio], :as => current_user.role.to_sym)
			end

		end
	end
end
