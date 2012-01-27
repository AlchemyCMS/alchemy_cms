module Alchemy
	module Admin
		class DashboardController < Alchemy::Admin::BaseController

			def index
				@alchemy_version = Alchemy::VERSION
				@clipboard_items = session[:clipboard]
				@last_edited_pages = Page.all_last_edited_from(current_user)
				@locked_pages = Page.all_locked
				@online_users = User.all_online.to_a.delete_if { |u| u == current_user }
			end

		end
	end
end
