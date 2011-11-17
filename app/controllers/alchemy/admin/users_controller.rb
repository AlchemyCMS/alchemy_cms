module Alchemy
	module Admin
		class UsersController < Alchemy::Admin::BaseController

			filter_access_to [:edit, :update, :destroy], :attribute_check => true, :load_method => :load_user, :model => Alchemy::User
			filter_access_to [:index, :new, :create], :attribute_check => false

			def index
				if !params[:query].blank?
					@users = User.where([
						"users.login LIKE ? OR users.email LIKE ? OR users.firstname LIKE ? OR users.lastname LIKE ?",
						"%#{params[:query]}%",
						"%#{params[:query]}%",
						"%#{params[:query]}%",
						"%#{params[:query]}%"
					]).order('login')
				else
					@users = User.all
				end
			end

			def new
				@user = User.new
				render :layout => false
			end

			def create
				@user = User.new(params[:user])
				if @user.save
					if @user.role == "registered" && params[:send_credentials]
						Notifications.registered_user_created(@user).deliver
					elsif params[:send_credentials]
						Notifications.admin_user_created(@user).deliver
					end
				end
				render_errors_or_redirect(
					@user,
					admin_users_path,
					( _("User: '%{name}' created") % {:name => @user.name} ),
					"form#new_user button.button"
				)
			end

			def edit
				# User is fetched via before filter
				render :layout => false
			end

			def update
				# User is fetched via before filter
				@user.update_attributes(params[:user])
				Notifications.admin_user_created(@user).deliver if params[:send_credentials]
				render_errors_or_redirect(
					@user,
					admin_users_path,
					( _("User: '%{name}' updated") % {:name => @user.name} ),
					"form#edit_user_#{@user.id} button.button"
				)
			end

			def destroy
				# User is fetched via before filter
				name = @user.name
				if @user.destroy
					flash[:notice] = ( _("User: '%{name}' deleted") % {:name => name} )
				end
				@redirect_url = admin_users_path
				render :action => :redirect
			end

		protected

			def load_user
				@user = User.find(params[:id])
			end

		end
	end
end
