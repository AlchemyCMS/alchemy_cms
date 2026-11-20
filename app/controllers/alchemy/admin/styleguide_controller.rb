# frozen_string_literal: true

module Alchemy
  module Admin
    class StyleguideController < BaseController
      # Growls are created from JavaScript, but demoing them from a link keeps
      # the styleguide free of inline scripts, which the admin CSP forbids.
      GROWL_MESSAGES = {
        "notice" => "Success message",
        "info" => "Info message",
        "warn" => "Warning message",
        "error" => "Error message"
      }.freeze

      authorize_resource class: :alchemy_admin_styleguide

      def index
        message = GROWL_MESSAGES[params[:growl]]
        flash.now[params[:growl]] = message if message
      end
    end
  end
end
