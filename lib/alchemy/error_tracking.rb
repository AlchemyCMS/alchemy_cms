# frozen_string_literal: true

module Alchemy
  module ErrorTracking
    class BaseHandler
      def self.call(exception)
        # implement your own notification method
      end
    end

    mattr_accessor :notification_handler
    @@notification_handler = BaseHandler
  end
end
