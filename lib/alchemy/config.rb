module Alchemy
  module Config
  
    # Returns the configuration for given parameter name from config/alchemy/config.yml file
    def self.get(name)
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
      config[name]
    end
    
    # Returns all available languages set inside config/alchemy/config.yml
    def self.available_languages
      languages = get(:languages)
      return [] if languages.blank?
      languages.collect{ |l| l[:language_code] }
    end
    
  end
end
