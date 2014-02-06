module Alchemy
  class UsersController < BaseController
    include Locale

    before_action { enforce_ssl if ssl_required? && !request.ssl? }
    before_action :check_user_count
    before_action :load_genders

    helper 'Alchemy::Admin::Base'

    layout 'alchemy/admin'

    def new
      @signup = true
      @user = User.new(send_credentials: true)
    end

    def create
      @user = User.new(user_params)
      @user.alchemy_roles = %w(admin)
      if @user.save
        flash[:notice] = _t('Successfully signup admin user')
        sign_in :user, @user
        redirect_to admin_dashboard_path
      else
        @signup = true
        render :new
      end
    rescue Errno::ECONNREFUSED => e
      flash[:error] = _t(:signup_mail_delivery_error)
      redirect_to admin_dashboard_path
    end

    private

    def load_genders
      @user_genders = User.genders_for_select
    end

    def check_user_count
      if User.count > 0
        redirect_to admin_dashboard_path
      end
    end

    def user_params
      params.require(:user).permit(*secure_attributes)
    end

    def secure_attributes
      User::PERMITTED_ATTRIBUTES
    end

  end
end
