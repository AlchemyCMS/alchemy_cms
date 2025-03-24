# frozen_string_literal: true

module Alchemy
  class Configuration
    class BaseOption
      def self.value_class
        raise NotImplementedError
      end

      def initialize(value:, name:, **args)
        @name = name
        validate(value) unless value.nil?
        @value = value
      end
      attr_reader :name, :value

      def validate(value)
        raise ConfigurationError.new(name, value, self.class.value_class.name) unless value.is_a?(self.class.value_class)
      end
    end
  end
end
