# frozen_string_literal: true

require "alchemy/version"

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_dashboard

      def index
      end

      def license
        @license = Alchemy::Engine.root.join("LICENSE").read
      end
    end
  end
end
