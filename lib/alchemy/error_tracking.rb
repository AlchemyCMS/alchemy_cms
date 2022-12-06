# frozen_string_literal: true

module Alchemy
  module ErrorTracking
    class BaseHandler
      def self.call(exception)
        # implement your own notification method
      end
    end

    mattr_accessor :notification_handler
  end
end

require "alchemy/error_tracking/error_logger"
Alchemy::ErrorTracking.notification_handler = Alchemy::ErrorTracking::ErrorLogger
