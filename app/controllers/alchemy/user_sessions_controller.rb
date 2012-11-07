module Alchemy
  class UserSessionsController < Alchemy::BaseController

    before_filter { enforce_ssl if ssl_required? && !request.ssl? }
    before_filter :set_translation
    before_filter :check_user_count, :only => :login

    layout 'alchemy/admin'

    helper 'Alchemy::Admin::Base'

    # Signup only works if no user is present in database.
    def signup
      @user_genders = User.genders_for_select
      if request.get?
        redirect_to admin_dashboard_path if User.count != 0
        @user = User.new({:role => 'admin'})
      else
        @user = User.new(params[:user])
        if @user.save
          if params[:send_credentials]
            Notifications.admin_user_created(@user).deliver
          end
          flash[:notice] = t('Successfully signup admin user')
          redirect_to admin_dashboard_path
        end
      end
    rescue Errno::ECONNREFUSED => e
      flash[:error] = t(:signup_mail_delivery_error)
      redirect_to admin_dashboard_path
    end

    def login
      if current_user
        redirect_to admin_dashboard_path, :notice => t('You are already logged in')
      else
        if request.get?
          @user_session = UserSession.new()
          flash.now[:info] = params[:message] || t("welcome_please_identify_notice")
        else
          @user_session = UserSession.new(params[:alchemy_user_session])
          store_screen_size
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
    end

    def leave
      render :layout => false
    end

    def logout
      message = params[:message] || t("logged_out")
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

    def store_screen_size
      session[:screen_size] = params[:user_screensize]
    end

  end
end
