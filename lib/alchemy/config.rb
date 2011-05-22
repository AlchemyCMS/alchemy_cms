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
      config_1 = {}
      config_2 = {}
      config_3 = {}
      name = name.to_sym if name.class == String
      
      # Looking for any Rails Environment specific configuration
      config_file_1 = "#{Rails.root.to_s}/config/alchemy/config_#{Rails.env}.yml"
      config_1 = YAML.load_file(config_file_1) if File.exists? config_file_1
      
      # Looking for Applikation specific configuration
      config_file_2 = "#{Rails.root.to_s}/config/alchemy/config.yml"
      config_2 = YAML.load_file(config_file_2) if File.exists? config_file_2
      
      # Reading Alchemy standard configuration
      config_file_3 = File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml')
      config_3 = YAML.load_file(config_file_3) if File.exists? config_file_3
      
      # Mergin all together
      config = config_3.merge(config_2.merge(config_1))
    end
    
  end
end
