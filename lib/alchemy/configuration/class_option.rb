# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class ClassOption < BaseOption
      def allowed_classes
        [String, Array]
      end

      def validate(value)
        super

        if value.is_a?(Array)
          validate_array!(value)
        end
      end

      def value
        @_cached_value ||= case @value
        when Array
          @value[0] = @value[0]&.constantize
          @value
        when String
          @value&.constantize
        end
      end

      private

      def validate_array!(value)
        @array = value
        has_length_two! && first_value_is_string! && second_value_is_hash!
      end

      def has_length_two!
        return true if @array.length == 2

        raise(ConfigurationError.new(name, @array, [
          Class.new(Array) { def self.name = "an Array of length two" }
        ]))
      end

      def first_value_is_string!
        return true if @array[0].is_a?(String)

        raise(ConfigurationError.new(name, @array[0], [String]))
      end

      def second_value_is_hash!
        return true if @array[1].is_a?(Hash)

        raise(ConfigurationError.new(name, @array[1], [Hash]))
      end
    end
  end
end
