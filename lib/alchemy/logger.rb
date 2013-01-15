module Alchemy
  module Logger

    # Logs a warning to the Rails standard logger and adds some nicer formatting
    def warn(message)
      logger.warn("+++++++++++\nWarning: #{message}\n+++++++++++")
      return nil
    end
    alias_method :warning, :warn

  end
end
