# frozen_string_literal: true

module Alchemy
  class Config
    class << self
      # Returns the configuration for given parameter name.
      #
      # @param name [String]
      #
      def get(name)
        check_deprecation(name)
        key = check_replacement(name)
        show[key.to_s]
      end

      alias_method :parameter, :get

      # Returns a merged configuration of the following files
      #
      # Alchemys default config: +gems/../alchemy_cms/config/alchemy/config.yml+
      # Your apps default config: +your_app/config/alchemy/config.yml+
      # Environment specific config: +your_app/config/alchemy/development.config.yml+
      #
      # An environment specific config overwrites the settings of your apps default config,
      # while your apps default config has precedence over Alchemys default config.
      #
      def show
        @config ||= merge_configs!(alchemy_config, main_app_config, env_specific_config)
      end

      # A list of deprecated configuration values
      # a value of nil means there is no new default
      # any not nil value is the new default
      def deprecated_configs
        {}
      end

      # A list of replaced configuration keys
      def replaced_config_keys
        {
          output_image_quality: :output_image_jpg_quality
        }
      end

      private

      # Alchemy default configuration
      def alchemy_config
        read_file(File.join(File.dirname(__FILE__), "..", "..", "config/alchemy/config.yml"))
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
        YAML.safe_load(
          ERB.new(File.read(file)).result,
          permitted_classes: YAML_PERMITTED_CLASSES,
          aliases: true
        ) || {}
      rescue Errno::ENOENT
        {}
      end

      # Merges all given configs together
      #
      def merge_configs!(*config_files)
        raise LoadError, "No Alchemy config file found!" if config_files.map(&:blank?).all?

        config = {}
        config_files.each { |h| config.merge!(h.stringify_keys!) }
        config
      end

      def check_deprecation(name)
        if deprecated_configs.key?(name.to_sym)
          config = deprecated_configs[name.to_sym]
          if config.nil?
            Alchemy::Deprecation.warn("#{name} configuration is deprecated and will be removed from Alchemy #{Alchemy::Deprecation.deprecation_horizon}")
          else
            value = show[name.to_s]
            if value != config
              Alchemy::Deprecation.warn("Setting #{name} configuration to #{value} is deprecated and will be always #{config} in Alchemy #{Alchemy::Deprecation.deprecation_horizon}")
            end
          end
        end
      end

      def check_replacement(name)
        if replaced_config_keys.key?(name.to_sym)
          old_key = replaced_config_keys[name.to_sym]
          if show[old_key.to_s]
            Alchemy::Deprecation.warn("Using #{old_key} configuration is deprecated and will be removed in Alchemy #{Alchemy::Deprecation.deprecation_horizon}. Please use #{name} instead.")
            old_key
          else
            name
          end
        else
          name
        end
      end
    end
  end
end
