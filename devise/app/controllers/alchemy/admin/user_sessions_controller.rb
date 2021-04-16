# frozen_string_literal: true

require "alchemy/version"

module Alchemy
  module Admin
    class UserSessionsController < ::Devise::SessionsController
      include Alchemy::Admin::Locale

      protect_from_forgery prepend: true

      if Alchemy.gem_version <= Gem::Version.new("4.9")
        before_action except: "destroy" do
          enforce_ssl if ssl_required? && !request.ssl?
        end
      end
      before_action :check_user_count, :only => :new

      helper "Alchemy::Admin::Base"

      layout Alchemy::Devise.layout

      def create
        authenticate_user!

        if user_signed_in?
          if session[:redirect_path].blank?
            redirect_path = admin_dashboard_path
          else
            # We have to strip double slashes from beginning of path, because of strange rails/rack bug.
            redirect_path = session[:redirect_path].gsub(/\A\/{2,}/, "/")
          end
          redirect_to redirect_path,
            notice: t(:signed_in, scope: "devise.sessions")
        else
          super
        end
      end

      def destroy
        current_alchemy_user.try(:unlock_pages!)
        cookies.clear
        session.clear
        super
      end

      private

      def check_user_count
        if User.count == 0
          redirect_to admin_signup_path
        end
      end

      # Overwriting the default of Devise
      def after_sign_out_path_for(resource_or_scope)
        if request.referer.blank? || request.referer.to_s =~ /admin/
          root_path
        else
          request.referer
        end
      end
    end
  end
end
