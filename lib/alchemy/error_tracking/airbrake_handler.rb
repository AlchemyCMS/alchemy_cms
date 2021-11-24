# frozen_string_literal: true

module Alchemy
  module ErrorTracking
    class AirbrakeHandler < BaseHandler
      def self.call(exception)
        return if ["development", "test"].include?(Rails.env)

        notify_airbrake(exception)
      end
    end
  end
end
