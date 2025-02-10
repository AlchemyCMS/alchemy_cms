# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/string"

require "alchemy/configuration/boolean_option"
require "alchemy/configuration/class_option"
require "alchemy/configuration/class_set_option"
require "alchemy/configuration/integer_option"
require "alchemy/configuration/integer_list_option"
require "alchemy/configuration/regexp_option"
require "alchemy/configuration/string_list_option"
require "alchemy/configuration/string_option"

module Alchemy
  class Configuration
    def initialize(configuration_hash = {})
      set(configuration_hash)
    end

    def set(configuration_hash)
      configuration_hash.each do |key, value|
        send(:"#{key}=", value)
      end
    end

    alias_method :get, :send
    alias_method :[], :get

    def show = self

    def fetch(key, default = nil)
      get(key) || default
    end

    def set_from_yaml(file)
      set(
        YAML.safe_load(
          ERB.new(File.read(file)).result,
          permitted_classes: YAML_PERMITTED_CLASSES,
          aliases: true
        ) || {}
      )
    end

    def to_h
      self.class.defined_options.map do |option|
        [option, send(option)]
      end.concat(
        self.class.defined_configurations.map do |configuration|
          [configuration, send(configuration).to_h]
        end
      ).to_h
    end

    class << self
      def defined_configurations = []

      def defined_options = []

      def configuration(name, configuration_class)
        # The defined configurations on a class are all those defined directly on
        # that class as well as those defined on ancestors.
        # We store these as a class instance variable on each class which has a
        # configuration. super() collects configurations defined on ancestors.
        singleton_configurations = (@defined_singleton_configurations ||= [])
        singleton_configurations << name.to_sym

        define_singleton_method :defined_configurations do
          super() + singleton_configurations
        end

        define_method(name) do
          unless instance_variable_get(:"@#{name}")
            send(:"#{name}=", configuration_class.new)
          end
          instance_variable_get(:"@#{name}")
        end

        define_method(:"#{name}=") do |value|
          if value.is_a?(configuration_class)
            instance_variable_set(:"@#{name}", value)
          else
            send(name).set(value)
          end
        end
      end

      def option(name, type, default: nil, **args)
        klass = "Alchemy::Configuration::#{type.to_s.camelize}Option".constantize
        # The defined options on a class are all those defined directly on
        # that class as well as those defined on ancestors.
        # We store these as a class instance variable on each class which has a
        # option. super() collects options defined on ancestors.
        singleton_options = (@defined_singleton_options ||= [])
        singleton_options << name.to_sym

        define_singleton_method :defined_options do
          super() + singleton_options
        end

        define_method(name) do
          unless instance_variable_defined?(:"@#{name}")
            send(:"#{name}=", default)
          end
          instance_variable_get(:"@#{name}").value
        end

        define_method(:"#{name}=") do |value|
          instance_variable_set(:"@#{name}", klass.new(value:, name:, **args))
        end
      end
    end
  end
end
