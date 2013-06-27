# encoding: utf-8

module Alchemy
  class Config

    class << self

      # Returns the configuration for given parameter name.
      #
      # @param name [String]
      #
      def get(name)
        show[name.to_s]
      end
      alias_method :parameter, :get

      # Returns a merged configuration of the following files
      # 
      # Alchemy´s default config: +gems/../alchemy_cms/config/alchemy/config.yml+
      # Your apps default config: +your_app/config/alchemy/config.yml+
      # Environment specific config: +your_app/config/alchemy/development.config.yml+
      #
      # An environment specific config overwrites the settings of your apps default config, 
      # while your apps default config has precedence over Alchemy´s default config.
      #
      def show
        @config ||= merge_configs!(alchemy_config, main_app_config, env_specific_config)
      end

    private

      # Alchemy default configuration
      def alchemy_config
        read_file(File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml'))
      end

      # Application specific configuration
      def main_app_config
        read_file("#{Rails.root}/config/alchemy/config.yml")
      end

      # Rails Environment specific configuration
      def env_specific_config
        read_file("#{Rails.root}/config/alchemy/#{Rails.env}.config.yml")
      end

      # Tries to load yaml file from given path.
      # If it does not exist, or its empty, it returns an empty Hash.
      #
      def read_file(file)
        return YAML.load_file(file) || {} if File.exists?(file) # YAML.load_file returns false if file is empty.
        {}
      end

      # Merges all given configs together
      # 
      def merge_configs!(*config_files)
        raise LoadError, 'No Alchemy config file found!' if config_files.map(&:blank?).all?
        config = {}
        config_files.each {|h| config.merge!(h.stringify_keys!) }
        config
      end

    end

  end
end
