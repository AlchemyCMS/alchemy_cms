require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')

module Alchemy
  class Engine < Rails::Engine

    # Config defaults
    config.mount_at = '/'

		# Enabling assets precompiling under rails 3.1
		if Rails.version >= '3.1'
			initializer :assets do |config|
				Rails.application.config.assets.precompile += %w( alchemy/alchemy.js alchemy/alchemy.css alchemy/print.css )
			end
		end

    # Check the gem config
    initializer "check config" do |app|
      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    initializer :flash_cookie do |config|
      config.middleware.insert_after(
        'ActionDispatch::Cookies',
        Alchemy::Middleware::FlashSessionCookie,
        ::Rails.configuration.session_options[:key]
      )
    end

  end
end
