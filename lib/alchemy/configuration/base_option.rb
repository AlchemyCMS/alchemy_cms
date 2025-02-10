# frozen_string_literal: true

module Alchemy
  class Configuration
    class BaseOption
      def self.value_class
        raise NotImplementedError
      end

      def initialize(value:, name:, **args)
        @name = name
        @value = validate(value) if value
      end
      attr_reader :name, :value

      private

      def validate(value)
        raise TypeError, "#{name} must be set as a #{self.class.value_class.name}, given #{value.inspect}" unless value.is_a?(self.class.value_class)
        value
      end
    end
  end
end
