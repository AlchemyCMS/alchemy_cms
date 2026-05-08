# frozen_string_literal: true

require "alchemy/version"

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_dashboard

      def index
      end

      def info
        @alchemy_version = Alchemy.version
      end
    end
  end
end
