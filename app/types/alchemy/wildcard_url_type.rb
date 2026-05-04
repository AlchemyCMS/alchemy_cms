# frozen_string_literal: true

module Alchemy
  class WildcardUrlType < ActiveModel::Type::Value
    def cast(value)
      case value
      when nil then nil
      when Symbol, String then normalize(value)
      else value
      end
    end

    def assert_valid_value(value)
      case value
      when nil
        nil
      when Symbol, String
        assert_valid_param!(normalize(value))
      else
        raise ArgumentError, "#{value.inspect} is not a valid wildcard_url. Must be a Symbol or String."
      end
    end

    private

    # Normalizes a wildcard_url input to a String. Symbols are turned into a
    # dynamic segment with a leading colon (`:slug` => `":slug"`).
    #
    # @param value [String, Symbol]
    # @return [String]
    def normalize(value)
      value.is_a?(Symbol) ? ":#{value}" : value.to_s
    end

    def assert_valid_param!(value)
      if value.include?("/")
        raise ArgumentError,
          "wildcard_url #{value.inspect}: cannot contain \"/\". " \
          "Must be a single URL segment."
      end

      unless value.match?(/:\w+/)
        raise ArgumentError,
          "wildcard_url #{value.inspect}: must contain a dynamic segment, e.g. \":id\"."
      end
    end
  end
end
