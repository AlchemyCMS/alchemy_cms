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
      # Alchemys default config: +gems/../alchemy_cms/config/alchemy/config.yml+
      # Other engine's default config: +gems/../ENGINE/config/alychemy/config.yml+
      # Your apps default config: +your_app/config/alchemy/config.yml+
      # Environment specific config: +your_app/config/alchemy/development.config.yml+
      #
      # An environment specific config overwrites the settings of your apps default config,
      # while your apps default config has precedence over Alchemys default config.
      #
      def show
        @config ||= loader.load_all
      end

      private

      def loader
        ConfigLoader.new(
          'config',
          before: alchemy_config_path,
          after: env_specific_config_path
        )
      end

      # Alchemy default configuration
      def alchemy_config_path
        Pathname.new File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml')
      end

      # Rails Environment specific configuration
      def env_specific_config_path
        Rails.root.join("config/alchemy/#{Rails.env}.config.yml")
      end
    end
  end
end
