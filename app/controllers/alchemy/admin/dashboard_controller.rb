# frozen_string_literal: true

require "net/http"
require "alchemy/version"

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_dashboard

      def index
        @last_edited_pages = Page.all_last_edited_from(current_alchemy_user)
        @all_locked_pages = Page.locked
        if Alchemy.config.user_class.respond_to?(:logged_in)
          @online_users = Alchemy.config.user_class.logged_in.to_a - [current_alchemy_user]
        end
        if current_alchemy_user.respond_to?(:sign_in_count) && current_alchemy_user.respond_to?(:last_sign_in_at)
          @last_sign_at = current_alchemy_user.last_sign_in_at
          @first_time = current_alchemy_user.sign_in_count == 1 && @last_sign_at.nil?
        end
        @sites = Site.all
      end

      def info
        @alchemy_version = Alchemy.version
      end
    end
  end
end
