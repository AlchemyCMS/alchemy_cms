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

    class << self
      def option(name, type, default: nil, **args)
        klass = "Alchemy::Configuration::#{type.to_s.camelize}Option".constantize

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
