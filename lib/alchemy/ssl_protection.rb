module Alchemy
  module SSLProtection
    private

    # Enforce ssl for login and all admin modules.
    #
    # Default is +false+
    #
    # === Usage
    #
    #   # config/alchemy/config.yml
    #   ...
    #   require_ssl: true
    #   ...
    #
    # === Note
    #
    # You have to create a ssl certificate
    # if you want to use the ssl protection.
    #
    def ssl_required?
      %w(development test).exclude?(Rails.env) && Config.get(:require_ssl)
    end

    # Redirects current request to https.
    def enforce_ssl
      redirect_to url_for(request.params.merge(protocol: 'https'))
    end
  end
end
