# frozen_string_literal: true

module Alchemy
  module Logger
    # Logs a debug message to the Rails standard logger and adds some nicer formatting
    def self.warn(message, caller_string)
      Rails.logger.debug %(\n++++ WARNING: #{message}\nCalled from: #{caller_string}\n)
      nil
    end

    def log_warning(message)
      Alchemy::Logger.warn(message, caller(1..1))
    end
  end
end
