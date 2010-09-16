require 'rails'
require 'alchemy/config'
require 'alchemy/controller'
require 'alchemy/action_view'
require 'alchemy/form_builder'
require 'alchemy/migrator'
require 'alchemy/notice'
require 'alchemy/page_layout'
require 'alchemy/tableless'

module Alchemy
  
  class Engine < Rails::Engine
    
    initializer "session.flash_session_cookie" do |app|
      app.config.middleware.use(FlashSessionCookieMiddleware, ActionController::Base.session[:key])
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
