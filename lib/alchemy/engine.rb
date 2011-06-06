require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')

module Alchemy
  class Engine < Rails::Engine
    
    # Config defaults
    #config.widget_factory_name = "Alchemy"
    config.mount_at = '/'
    
    # Load rake tasks
    rake_tasks do
      load File.join(File.dirname(__FILE__), '../tasks/alchemy.rake')
    end
    
    # Check the gem config
    initializer "check config" do |app|
      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end
    
    initializer :flash_cookie do |config|
      config.middleware.use Alchemy::Middleware::FlashSessionCookie
    end
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    # config.after_initialize do
    #   ActionController::Dispatcher.middleware.insert_before(
    #     ActionController::Base.session_store,
    #     Alchemy::Middleware::FlashSessionCookie,
    #     ActionController::Base.session_options[:key]
    #   )
    # end
    
  end
  
end
