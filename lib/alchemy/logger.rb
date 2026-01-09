# frozen_string_literal: true

module Alchemy
  module Logger
    # Logs a debug message to the Rails standard logger
    def self.debug(message)
      Rails.logger.tagged("alchemy") do
        Rails.logger.debug(message)
      end
      nil
    end

    # Logs a error message to the Rails standard logger
    def self.error(message)
      Rails.logger.tagged("alchemy") do
        Rails.logger.error(message)
      end
      nil
    end

    # Logs a info message to the Rails standard logger
    def self.info(message)
      Rails.logger.tagged("alchemy") do
        Rails.logger.info(message)
      end
      nil
    end

    # Logs a warning message to the Rails standard logger
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
