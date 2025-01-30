# frozen_string_literal: true

module Alchemy
  class Configuration
    class IntegerOption
      def initialize(value:, name:, **args)
        @name = name
        @value = validate(value) if value
      end
      attr_reader :value, :name

      private

      def validate(value)
        raise TypeError, "#{name} must be an integer, given #{value.inspect}" unless value.is_a?(Integer)
        value
      end
    end
  end
end
