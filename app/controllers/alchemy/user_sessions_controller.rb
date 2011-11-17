module Alchemy
	class UserSessionsController < Alchemy::BaseController
		before_filter :check_user_count, :only => :login
		layout 'alchemy/login'

		# Signup only works if no user is present in database.
		def signup
			if request.get?
				redirect_to admin_path if User.count != 0
				@user = User.new({:role => 'admin'})
			else
				@user = User.new(params[:user])
				if @user.save
					if params[:send_credentials]
						Notifications.admin_user_created(@user).deliver
					end
					redirect_to :action => :index
				end
			end
		end

		def login
			if request.get?
				@user_session = UserSession.new()
				flash.now[:info] = params[:message] || _("welcome_please_identify_notice")
			else
				@user_session = UserSession.new(params[:alchemy_user_session])
				if @user_session.save
					if session[:redirect_path].blank?
						redirect_to admin_dashboard_path
					else
						# We have to strip double slashes from beginning of path, because of strange rails/rack bug.
						redirect_to session[:redirect_path].gsub(/^\/{2,}/, '/')
					end
				else
					render
				end
			end
		end

		def leave
			render :layout => false
		end

		def logout
			message = params[:message] || _("logged_out")
			@user_session = UserSession.find
			if @user_session
				@user_session.destroy
			end
			flash[:info] = message
			redirect_to root_url
		end

	private

		def check_user_count
			if User.count == 0
				redirect_to :action => 'signup'
			else
				return true
			end
		end

	end
end
