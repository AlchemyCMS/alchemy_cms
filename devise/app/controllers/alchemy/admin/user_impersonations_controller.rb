# frozen_string_literal: true

module Alchemy
  module Admin
    class UserImpersonationsController < Alchemy::BaseController
      ORIGINAL_USER_ID_SESSION_KEY = :alchemy_devise_original_user_id

      before_action :require_user, only: :create
      skip_before_action :set_current_alchemy_user, only: :destroy
      skip_before_action :store_user_request_time, only: :destroy

      def create
        target = Alchemy::User.find(params[:user_id])
        authorize! :impersonate, target
        raise CanCan::AccessDenied if impersonating?

        session[ORIGINAL_USER_ID_SESSION_KEY] = current_alchemy_user.id
        warden.set_user(target, scope: :user)
        redirect_to impersonation_redirect_path, allow_other_host: false
      end

      def destroy
        raise CanCan::AccessDenied unless impersonating?

        original_user = original_user_for_restoration
        clear_impersonation

        if original_user
          warden.set_user(original_user, scope: :user)
          redirect_to admin_users_path, allow_other_host: false
        else
          warden.logout(:user)
          redirect_to Alchemy.config.login_path, allow_other_host: false
        end
      end

      private

      def require_user
        return if current_alchemy_user

        raise CanCan::AccessDenied
      end

      def impersonating?
        session[ORIGINAL_USER_ID_SESSION_KEY].present?
      end

      def original_user_for_restoration
        return unless impersonating?

        Alchemy::User.find_by(id: session[ORIGINAL_USER_ID_SESSION_KEY]).then do |user|
          user if user&.active_for_authentication? && user.alchemy_admin?
        end
      end

      def clear_impersonation
        session.delete(ORIGINAL_USER_ID_SESSION_KEY)
      end

      def impersonation_redirect_path
        path = Alchemy::Devise.config.user_impersonation_redirect_path.to_s
        return path if path.start_with?("/") && !path.start_with?("//")

        "/"
      end
    end
  end
end
