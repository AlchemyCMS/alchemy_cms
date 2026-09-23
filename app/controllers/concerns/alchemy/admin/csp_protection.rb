# frozen_string_literal: true

module Alchemy
  module Admin
    # Applies Alchemy's own Content Security Policy to the including controller.
    #
    # Include it into any controller that renders the Alchemy admin but does not
    # inherit from +Alchemy::Admin::BaseController+, so that its responses carry
    # the same policy as the rest of the admin:
    #
    #     class Alchemy::Admin::PasswordsController < Devise::PasswordsController
    #       include Alchemy::Admin::CspProtection
    #     end
    #
    # Including it is opting in, so the policy applies to every action. Override
    # +apply_content_security_policy?+ to narrow that down.
    #
    # The policy itself comes from +Alchemy.config.admin_content_security_policy+
    # and is left alone when the host application configured one of its own.
    module CspProtection
      extend ActiveSupport::Concern

      included do
        before_action :set_content_security_policy, if: :apply_content_security_policy?
      end

      private

      def apply_content_security_policy? = true

      def set_content_security_policy
        policy_class = Alchemy.config.admin_content_security_policy
        return unless policy_class
        return if request.content_security_policy

        policy = policy_class.new(request)
        request.content_security_policy_nonce_generator ||= policy.nonce_generator
        request.content_security_policy = policy.call
        request.content_security_policy_report_only = policy.report_only?
      end
    end
  end
end
