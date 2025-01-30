# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/string"

require "alchemy/configuration/boolean_option"
require "alchemy/configuration/integer_option"
require "alchemy/configuration/class_option"
require "alchemy/configuration/class_set_option"

module Alchemy
  class Configuration
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
