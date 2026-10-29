# frozen_string_literal: true

module Alchemy
  module Devise
    module UserImpersonationHelper
      def alchemy_user_impersonating?
        session[Alchemy::Admin::UserImpersonationsController::ORIGINAL_USER_ID_SESSION_KEY].present?
      end

      def alchemy_user_impersonation_notice
        user = current_impersonated_user
        return unless alchemy_user_impersonating? && user

        render "alchemy/devise/user_impersonation_notice", user: user
      end

      private

      def current_impersonated_user
        current_user_method = Alchemy.config.current_user_method
        return unless controller.respond_to?(current_user_method, true)

        controller.send(current_user_method)
      end
    end
  end
end
