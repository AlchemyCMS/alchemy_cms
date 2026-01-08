# frozen_string_literal: true

module Alchemy
  module Logger
    # Logs a debug message to the Rails standard logger and adds some nicer formatting
    def self.warn(message, caller_string = nil)
      if caller_string
        Alchemy::Deprecation.warn("Alchemy::Logger.warn second argument is deprecated and will be removed in Alchemy 9.0")
      end
      Rails.logger.tagged("alchemy") do
        Rails.logger.warn(message)
      end
      nil
    end

    def log_warning(message)
      Alchemy::Logger.warn(message)
    end
    deprecate log_warning: "Alchemy::Logger.warn", deprecator: Alchemy::Deprecation
  end
end
