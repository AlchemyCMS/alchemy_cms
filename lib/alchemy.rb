module Alchemy
  
  class Engine < Rails::Engine
    engine_name :alchemy
    config.middleware.use FlashSessionCookieMiddleware
    paths.config              = File.join(File.dirname(__FILE__)}, '..', 'config')
    paths.config.initializers = File.join(File.dirname(__FILE__)}, '..', 'config', 'initializers')
    paths.config.locales      = File.join(File.dirname(__FILE__)}, '..', 'config', 'locales')
    paths.config.routes       = File.join(File.dirname(__FILE__)}, '..', 'config', 'routes.rb')
    rake_tasks do
      load "#{File.dirname(__FILE__)}/tasks/alchemy.rake"
    end
  end
  
  def self.version
    version = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'VERSION')).symbolize_keys
    "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  end
  
end
