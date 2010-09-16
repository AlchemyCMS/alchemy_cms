require 'rails'

module Alchemy
  
  class Engine < Rails::Engine
    
    paths.config              = 'config'
    paths.config.initializers = 'config/initializers'
    paths.config.locales      = 'config/locales'
    paths.config.routes       = 'config/routes.rb'
    
    initializer "session.flash_session_cookie" do |app|
      app.config.middleware.use(FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
    end
    
    rake_tasks do
      load "#{File.dirname(__FILE__)}/tasks/alchemy.rake"
    end
    
  end
  
  def self.version
    version = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'VERSION')).symbolize_keys
    "#{version[:major]}.#{version[:minor]}.#{version[:patch]}.#{version[:build]}"
  end
  
end
