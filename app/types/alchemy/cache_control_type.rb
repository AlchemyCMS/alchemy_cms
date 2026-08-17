# frozen_string_literal: true

module Alchemy
  # Casts a page layout `cache` / element `page_cache` config value into an
  # {Alchemy::CacheControl} and validates the hash grammar at definition-load
  # time (see {#assert_valid_value}, called eagerly on attribute assignment).
  class CacheControlType < ActiveModel::Type::Value
    ALLOWED_KEYS = [:visibility, :max_age, :no_cache, :no_store].freeze

    def cast(value)
      Alchemy::CacheControl.parse(value)
    end

    def assert_valid_value(value)
      case value
      when nil, true, false, Alchemy::CacheControl
        nil
      when Integer
        assert_valid_max_age!(value)
      when Hash
        assert_valid_hash!(value)
      else
        raise ArgumentError,
          "#{value.inspect} is not a valid cache setting. " \
          "Must be true, false, an Integer, or a Hash."
      end
    end

    private

    def assert_valid_hash!(hash)
      options = hash.transform_keys(&:to_sym)

      unknown = options.keys - ALLOWED_KEYS
      if unknown.any?
        raise ArgumentError,
          "unknown cache option(s) #{unknown.map(&:inspect).join(", ")}. " \
          "Allowed: #{ALLOWED_KEYS.map(&:inspect).join(", ")}."
      end

      assert_valid_visibility!(options[:visibility]) if options.key?(:visibility)
      assert_valid_max_age!(options[:max_age]) if options.key?(:max_age)
      assert_boolean!(:no_cache, options[:no_cache]) if options.key?(:no_cache)
      assert_boolean!(:no_store, options[:no_store]) if options.key?(:no_store)
      assert_no_conflicts!(options)
    end

    def assert_valid_visibility!(value)
      unless CacheControl::VISIBILITIES.include?(value.to_s.to_sym)
        raise ArgumentError,
          "cache visibility #{value.inspect} is invalid. Must be :public or :private."
      end
    end

    def assert_valid_max_age!(value)
      unless value.is_a?(Integer) && value >= 0
        raise ArgumentError,
          "cache max_age #{value.inspect} is invalid. Must be a non-negative Integer."
      end
    end

    def assert_boolean!(key, value)
      unless [true, false].include?(value)
        raise ArgumentError, "cache #{key} #{value.inspect} is invalid. Must be true or false."
      end
    end

    def assert_no_conflicts!(options)
      if options[:no_store]
        conflicting = [:max_age, :visibility, :no_cache].select { |k| truthy?(options, k) }
        if conflicting.any?
          raise ArgumentError,
            "cache no_store cannot be combined with #{conflicting.map(&:inspect).join(", ")}."
        end
      elsif options[:no_cache] && options.key?(:max_age)
        raise ArgumentError, "cache no_cache cannot be combined with max_age."
      end
    end

    def truthy?(options, key)
      options.key?(key) && options[key]
    end
  end
end
