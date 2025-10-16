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
        raise ConfigurationError.new(name, value, allowed_classes) unless allowed_classes.any? { value.is_a?(_1) }
      end

      def allowed_classes
        [self.class.value_class]
      end

      def raw_value = @value

      def ==(other)
        self.class == other.class && raw_value == other.raw_value
      end
      alias_method :eql?, :==

      def hash
        [self.class, raw_value].hash
      end
    end
  end
end
