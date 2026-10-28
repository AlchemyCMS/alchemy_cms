# frozen_string_literal: true

module Alchemy
  module Devise
    module UserImpersonationHelper
      def alchemy_user_impersonating?
        session[Alchemy::Admin::UserImpersonationsController::ORIGINAL_USER_ID_SESSION_KEY].present?
      end

      def alchemy_user_impersonation_notice
        return unless alchemy_user_impersonating? && current_alchemy_user

        render "alchemy/devise/user_impersonation_notice", user: current_alchemy_user
      end
    end
  end
end
