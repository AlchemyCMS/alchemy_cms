module Alchemy
	module Admin
		class LayoutpagesController < Alchemy::Admin::BaseController

			def index
				@locked_pages = Page.all_locked_by(current_user)
				@layout_root = Page.find_or_create_layout_root_for(session[:language_id])
				@languages = Language.all
			end

		end
	end
end
