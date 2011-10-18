module Alchemy
  module Config
  
    def self.parameter(name)
      show[name.to_s]
    end
    
    # Returns the configuration for given parameter name from config/alchemy/config.yml file
    def self.get(name)
      parameter(name)
    end
    
    def self.show
      read_files
    end
    
  private
    
    def self.read_files
      # Looking for any Rails Environment specific configuration
      if File.exists? "#{Rails.root.to_s}/config/alchemy/config_#{Rails.env}.yml"
        config_1 = YAML.load_file( "#{Rails.root.to_s}/config/alchemy/config_#{Rails.env}.yml" )
      else
        config_1 = {}
      end
      
      # Looking for Application specific configuration
      if File.exists? "#{Rails.root.to_s}/config/alchemy/config.yml"
        config_2 = YAML.load_file( "#{Rails.root.to_s}/config/alchemy/config.yml" )
      else
        config_2 = {}
      end
      
      # Reading Alchemy standard configuration
      if File.exists? File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml')
        config_3 = YAML.load_file( File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml') )
      else
        config_3 = {}
      end
      
      # Mergin all together
      if config_1.blank? && config_3.blank? && config_3.blank?
        raise LoadError, 'No Alchemy config file found!'
      else
        [config_1, config_2, config_3].map(&:stringify_keys!)
        return config_3.merge(config_2.merge(config_1))
      end
    end
    
  end
end
