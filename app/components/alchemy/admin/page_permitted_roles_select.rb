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

      # The configured user roles. Only configured roles are selectable, and a
      # validation rejects any unknown role, so the select offers these only.
      #
      def role_options
        @_role_options ||= Alchemy.config.user_roles.map do |role|
          [Alchemy.t(role, scope: :user_roles, default: role.humanize), role]
        end
      end
    end
  end
end
