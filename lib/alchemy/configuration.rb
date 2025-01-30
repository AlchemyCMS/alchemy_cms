# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/string"
require "alchemy/configuration/integer_option"

module Alchemy
  class Configuration
    class << self
      def option(name, type, default: nil, **args)
        klass = "Alchemy::Configuration::#{type.to_s.camelize}Option".constantize

        define_method(name) do
          (instance_variable_get(:"@#{name}") || klass.new(value: default, **args)).value
        end

        define_method(:"#{name}=") do |value|
          instance_variable_set(:"@#{name}", klass.new(value:, **args))
        end
      end
    end
  end
end
