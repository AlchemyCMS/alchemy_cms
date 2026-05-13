# frozen_string_literal: true

require "alchemy/version"

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_dashboard

      def index
      end

      def info
        Alchemy::Deprecation.warn <<~WARN
          Requesting `admin/dashboard/info` is deprecated. Please render Alchemy::Admin::Dashboard::Widgets::SystemInfo instead.
        WARN
      end
    end
  end
end
