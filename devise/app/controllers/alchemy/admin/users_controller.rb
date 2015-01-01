module Alchemy
  module Admin
    class UsersController < ResourcesController

      before_action :set_roles_and_genders, except: [:index, :destroy]

      load_and_authorize_resource class: Alchemy::User,
        only: [:edit, :update, :destroy]

      authorize_resource class: Alchemy::User,
        only: [:index, :new, :create]

      handles_sortable_columns do |c|
        c.default_sort_value = :login
      end

      def index
        if params[:query].present?
          @users = User.search(params[:query])
        else
          @users = User.all
        end

        @users = @users
          .page(params[:page] || 1)
          .per(per_page_value_for_screen_size)
          .order(sort_order)
      end

      def new
        @user = User.new(send_credentials: true)
      end

      def create
        @user = User.create(user_params)
        render_errors_or_redirect(
          @user,
          admin_users_path,
          _t("User created", :name => @user.name)
        )
      end

      def update
        # User is fetched via before filter
        if params[:user][:password].present?
          @user.update_attributes(user_params)
        else
          @user.update_without_password(user_params)
        end
        render_errors_or_redirect(
          @user,
          admin_users_path,
          _t("User updated", :name => @user.name)
        )
      end

      def destroy
        # User is fetched via before filter
        name = @user.name
        if @user.destroy
          flash[:notice] = _t("User deleted", name: name)
        end
        do_redirect_to admin_users_path
      end

      private

      def set_roles_and_genders
        @user_roles = User::ROLES.map { |role| [User.human_rolename(role), role] }
        @user_genders = User.genders_for_select
      end

      def user_params
        params.require(:user).permit(*secure_attributes)
      end

      def secure_attributes
        if can?(:update_role, Alchemy::User)
          User::PERMITTED_ATTRIBUTES + [{alchemy_roles: []}]
        else
          User::PERMITTED_ATTRIBUTES
        end
      end

    end
  end
end
