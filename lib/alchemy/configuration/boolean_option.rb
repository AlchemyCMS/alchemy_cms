# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class BooleanOption < BaseOption
      private

      def validate(value)
        raise TypeError, "#{name} must be a Boolean, given #{value.inspect}" unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
        value
      end
    end
  end
end
