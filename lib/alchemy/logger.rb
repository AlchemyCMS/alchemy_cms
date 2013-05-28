module Alchemy
  module Logger

    # Logs a warning to the Rails standard logger and adds some nicer formatting
    def self.warn(message, caller_string)
      Rails.logger.warn %(\n++++ WARNING: #{message}\nCalled from: #{caller_string}\n)
      return nil
    end

    def log_warning(message)
      Alchemy::Logger.warn(message, caller.first)
    end

  end
end
