module Alchemy
  class UserSessionsController < Devise::SessionsController
    helper 'Alchemy::Admin::Base', 'Alchemy::Pages'

    before_filter(except: 'destroy') { enforce_ssl if ssl_required? && !request.ssl? }
    before_filter :set_translation
    before_filter :check_user_count, :only => :new

    layout 'alchemy/login'

    def new
      super
    end

    def create
      authenticate_user!
      if user_signed_in?
        store_screen_size
        if session[:redirect_path].blank?
          redirect_path = admin_dashboard_path
        else
          # We have to strip double slashes from beginning of path, because of strange rails/rack bug.
          redirect_path = session[:redirect_path].gsub(/\A\/{2,}/, '/')
        end
        redirect_to redirect_path, :notice => t(:signed_in, :scope => 'devise.sessions')
      else
        super
      end
    end

    def destroy
      cookies.clear
      session.clear
      super
    end

  private

    def check_user_count
      if User.count == 0
        redirect_to signup_path
      else
        return true
      end
    end

    def store_screen_size
      session[:screen_size] = params[:user_screensize]
    end

    # Ovewriting the default of Devise
    def after_sign_out_path_for(resource_or_scope)
      if request.referer.blank? || request.referer.to_s =~ /admin/
        root_path
      else
        request.referer
      end
    end

  end
end
