module Alchemy

  # Routing constraints for Alchemy's strong catch all route.
  #
  # Alchemy has a very strong catch all route.
  # But we don't want to handle all requests.
  #
  # For instance we only want to handle html requests and
  # don't want to swallow the rails/info routes in development mode.
  #
  class RoutingConstraints
    LOCALE_REGEXP = /[a-z]{2}(-[a-z]{2})?/

    def matches?(request)
      @request = request
      @params = @request.params

      handable_format? && no_rails_route?
    rescue ArgumentError => e
      handle_invalid_byte_sequence(e)
    end

    private

    # We only want html requests to be handled by us.
    #
    # If an unknown format is requested we want to handle this,
    # because it could be a legacy route that needs to be redirected.
    #
    def handable_format?
      @request.format.symbol.nil? || (@request.format.symbol == :html)
    end

    # We don't want to handle the Rails info routes.
    def no_rails_route?
      return true if !%w(development test).include?(Rails.env)
      (@params['urlname'] =~ /\Arails\//).nil?
    end

    # Handle invalid byte sequence in UTF-8 errors with 400 status.
    def handle_invalid_byte_sequence(e)
      if e.message =~ /invalid byte sequence/
        raise ActionController::BadRequest
      else
        raise
      end
    end
  end
end
