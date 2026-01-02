# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/string"

require "alchemy/configuration/boolean_option"
require "alchemy/configuration/collection_option"
require "alchemy/configuration/configuration_option"
require "alchemy/configuration/class_option"
require "alchemy/configuration/integer_option"
require "alchemy/configuration/pathname_option"
require "alchemy/configuration/regexp_option"
require "alchemy/configuration/string_option"
require "alchemy/configuration/symbol_option"

module Alchemy
  class Configuration
    class ConfigurationError < StandardError
      attr_reader :name, :value, :allowed_classes

      def initialize(name, value, allowed_classes)
        @name = name
        @value = value
        @allowed_classes = allowed_classes
        expected_classes_message = allowed_classes.map(&:name).to_sentence(two_words_connector: " or ", last_word_connector: ", or ")
        super("Invalid configuration value for #{name}: #{value.inspect} (expected #{expected_classes_message})")
      end
    end

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
    alias_method :configure, :tap

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
        value = send(option)
        [option, value.respond_to?(:to_serializable_array) ? value.to_serializable_array : value]
      end.concat(
        self.class.defined_configurations.map do |configuration|
          [configuration, send(configuration).to_h]
        end
      ).to_h
    end

    class << self
      def defined_configurations = []

      def defined_options = []

      def defined_values
        defined_options + defined_configurations
      end

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

        define_method("#{name}_option") do
          unless instance_variable_defined?(:"@#{name}")
            send(:"#{name}=", default)
          end
          instance_variable_get(:"@#{name}")
        end

        define_method(name) do
          send("#{name}_option").value
        end

        define_method("raw_#{name}") do
          send("#{name}_option").raw_value
        end

        define_method(:"#{name}=") do |value|
          instance_variable_set(:"@#{name}", klass.new(value:, name:, **args))
        end
      end
    end

    def hash
      self.class.defined_values.map do |ivar|
        [ivar, send(ivar).hash]
      end.hash
    end

    def ==(other)
      equal?(other) || self.class == other.class && self.class.defined_values.all? do |var|
        send(var) == other.send(var)
      end
    end
    alias_method :eql?, :==
  end
end
