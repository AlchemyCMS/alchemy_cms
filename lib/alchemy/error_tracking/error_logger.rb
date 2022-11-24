# frozen_string_literal: true

module Alchemy
  module ErrorTracking
    class ErrorLogger < BaseHandler
      def self.call(exception)
        ::Rails.logger.tagged("alchemy_cms") do
          ::Rails.logger.error("#{exception.class.name}: #{exception.message} in #{exception.backtrace.first}")
        end
      end
    end
  end
end
