require 'net/http'
require 'alchemy/version'

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      include ::Apotomo::Rails::ControllerMethods

      authorize_resource class: :alchemy_admin_dashboard

      @@dashboard = Dashboard.new.setup_widgets self

      def index
        if current_alchemy_user.respond_to?(:sign_in_count) && current_alchemy_user.respond_to?(:last_sign_in_at)
          @last_sign_at = current_alchemy_user.last_sign_in_at
          @first_time = current_alchemy_user.sign_in_count == 1 && @last_sign_at.nil?
        end
        @widgets = @@dashboard.widgets
      end

    # private

    #   def self.dashboard
    #     @@dashboard ||= Dashbord.new
    #   end

    end
  end
end
