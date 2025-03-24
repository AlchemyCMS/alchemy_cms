# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class BooleanOption < BaseOption
      def validate(value)
        raise ConfigurationError.new(name, value, "Boolean") unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
        value
      end
    end
  end
end
