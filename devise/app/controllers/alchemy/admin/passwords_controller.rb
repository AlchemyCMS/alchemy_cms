# frozen_string_literal: true

require "alchemy/version"

module Alchemy
  module Admin
    class PasswordsController < ::Devise::PasswordsController
      include Alchemy::Admin::Locale

      helper "Alchemy::Admin::Base"

      layout Alchemy::Devise.config.layout

      private

      # Override for Devise method
      def new_session_path(resource_name)
        alchemy.admin_login_path
      end

      def admin_edit_password_url(_resource, options = {})
        alchemy.admin_edit_password_url(options)
      end

      def after_resetting_password_path_for(resource)
        if can? :index, :alchemy_admin_dashboard
          alchemy.admin_dashboard_path
        else
          alchemy.root_path
        end
      end
    end
  end
end
