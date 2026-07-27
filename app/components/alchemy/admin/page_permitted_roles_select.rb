# frozen_string_literal: true

module Alchemy
  module Admin
    # Renders the multi select of roles that are permitted to read a restricted
    # page.
    #
    # Only visible while the +restricted+ checkbox is checked. While hidden the
    # select is disabled, so it does not submit and clear the stored roles.
    #
    class PagePermittedRolesSelect < ViewComponent::Base
      def initialize(page:, form:)
        @page = page
        @form = form
      end

      private

      attr_reader :form

      def disabled?
        !@page.restricted? || @page.attribute_fixed?(:restricted)
      end

      # All user roles, plus any role already assigned to this page.
      #
      # Roles are not validated against the configuration, so a page can hold a
      # role that is no longer (or was never) configured. Offering it keeps it
      # selected instead of silently dropping it on the next save.
      #
      def role_options
        @_role_options ||= (Alchemy.config.user_roles.to_a | @page.permitted_roles).map do |role|
          [Alchemy.t(role, scope: :user_roles, default: role.humanize), role]
        end
      end
    end
  end
end
