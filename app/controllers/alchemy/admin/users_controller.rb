module Alchemy
	module Admin
		class UsersController < Alchemy::Admin::BaseController

			filter_access_to [:edit, :update, :destroy], :attribute_check => true, :load_method => :load_user, :model => Alchemy::User
			filter_access_to [:index, :new, :create], :attribute_check => false

			def index
				if !params[:query].blank?
					users = User.where([
						"login LIKE ? OR email LIKE ? OR firstname LIKE ? OR lastname LIKE ?",
						"%#{params[:query]}%",
						"%#{params[:query]}%",
						"%#{params[:query]}%",
						"%#{params[:query]}%"
					])
				else
					users = User.scoped
				end
				@users = users.page(params[:page] || 1).per(per_page_value_for_screen_size).order('login')
			end

			def new
				@user = User.new
				@user_roles = User::ROLES.map { |role| [User.human_rolename(role), role]}
				@user_genders = User.genders_for_select
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
					t("User created", :name => @user.name)
				)
			end

			def edit
				@user_roles = User::ROLES.map { |role| [User.human_rolename(role), role]}
				@user_genders = User.genders_for_select
				render :layout => false
			end

			def update
				# User is fetched via before filter
				@user.update_attributes(params[:user])
				Notifications.admin_user_created(@user).deliver if params[:send_credentials]
				render_errors_or_redirect(
					@user,
					admin_users_path,
					t("User updated", :name => @user.name)
				)
			end

			def destroy
				# User is fetched via before filter
				name = @user.name
				if @user.destroy
					flash[:notice] = t("User deleted", :name => name)
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
