module Alchemy
	module Admin
		class EssenceFlashesController < Alchemy::Admin::BaseController

			def update
				@essence_flash = EssenceFlash.find(params[:id])
				@essence_flash.update_attributes(params[:essence_flash], :as => current_user.role.to_sym)
			end

		end
	end
end
