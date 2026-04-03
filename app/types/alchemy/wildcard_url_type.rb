# frozen_string_literal: true

module Alchemy
  class WildcardUrlType < ActiveModel::Type::Value
    class Value
      attr_reader :pattern, :params

      def initialize(pattern:, params: {})
        @pattern = pattern
        @params = params
      end

      def present?
        pattern.present?
      end
    end

    def cast(value)
      case value
      when nil then nil
      when String
        Value.new(pattern: value)
      when Hash
        attrs = value.symbolize_keys
        Value.new(
          pattern: attrs[:pattern],
          params: attrs[:params] || {}
        )
      else
        value
      end
    end

    def assert_valid_value(value)
      return if value.nil?

      unless value.is_a?(String) || value.is_a?(Hash)
        raise ArgumentError, "#{value.inspect} is not a valid wildcard_url. Must be a String or Hash."
      end

      if value.is_a?(Hash)
        attrs = value.symbolize_keys
        unless attrs[:pattern].is_a?(String)
          raise ArgumentError, "wildcard_url hash must include a \"pattern\" key with a String value."
        end
      end
    end
  end
end
