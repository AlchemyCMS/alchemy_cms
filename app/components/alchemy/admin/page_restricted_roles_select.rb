# frozen_string_literal: true

module Alchemy
  module Admin
    # Renders the multi select of roles a restricted page is readable by.
    #
    # Only visible while the +restricted+ checkbox is checked. While hidden the
    # select is disabled, so it does not submit and clear the stored roles.
    #
    class PageRestrictedRolesSelect < ViewComponent::Base
      def initialize(page:)
        @page = page
      end

      # Configuring no roles at all opts out of the feature. The select is then
      # not rendered and does not submit, leaving stored roles untouched.
      #
      def render?
        Alchemy.config.restricted_roles.any?
      end

      private

      def disabled?
        !@page.restricted? || @page.attribute_fixed?(:restricted)
      end

      # The configured roles, plus any role already assigned to this page.
      #
      # Roles are not validated against the configuration, so a page can hold a
      # role that is no longer (or was never) configured. Offering it keeps it
      # selected instead of silently dropping it on the next save.
      #
      def role_options
        @_role_options ||= (Alchemy.config.restricted_roles.to_a | @page.restricted_roles).map do |role|
          [Alchemy.t(role, scope: :restricted_roles, default: role.humanize), role]
        end
      end
    end
  end
end
