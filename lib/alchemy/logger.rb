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
        Rails.logger.error("ERROR: #{message}")
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
    def self.warn(message)
      Rails.logger.tagged("alchemy") do
        Rails.logger.warn("WARNING: #{message}")
      end
      nil
    end
  end
end
