require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')

module Alchemy
  class Engine < Rails::Engine

    # Config defaults
    #config.widget_factory_name = "Alchemy"
    config.mount_at = '/'

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

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
