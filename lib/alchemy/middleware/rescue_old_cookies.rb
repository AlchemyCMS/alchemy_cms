module Alchemy
  module Middleware
    class RescueOldCookies
      def initialize(app)
        @app = app
      end

      def call(env)
        begin
          @app.call(env)
        rescue NameError => error
          if error.to_s =~ /uninitialized constant Alchemy::Clipboard/
            message = "<h2>You have an old style Alchemy clipboard in your session!</h2>"
            message += "<h3>Please remove your cookies and try again.</h3>"
            Rails.logger.error(error)
            return [
              500, { "Content-Type" => "text/html" },
              [message]
            ]
          else
            raise error
          end
        end
      end
    end
  end
end
