# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    # A map option whose keys are plain strings and whose values are class name
    # strings that are lazily constantized on first access.
    #
    # Intended for mappings like:
    #
    #   config.ingredient_preloaders = {
    #     "Alchemy::Ingredients::Picture" => "MyApp::Preloaders::PicturePreloader"
    #   }
    #
    # Values are constantized the first time they are read via +[]+, +fetch+,
    # or +each_pair+ / +each+. Runtime additions via +[]=+ or +merge!+ are
    # supported; the new values are constantized lazily on next access.
    class ClassMapOption < BaseOption
      include Enumerable

      def self.value_class
        Hash
      end

      def initialize(value:, name:, **args)
        @name = name
        value = {} if value.nil?
        validate(value) unless value.nil?
        super(value: value.transform_keys(&:to_s), name: name)
        @resolved = {}
      end

      # Returns the constantized value class for the given key, or nil if the
      # key is absent.
      def [](key)
        key = key.to_s
        return nil unless @value.key?(key)

        @resolved[key] ||= @value[key].constantize
      end

      # Adds or replaces a mapping at runtime. The value class name is stored
      # as a string and constantized lazily.
      def []=(key, value_class_name)
        key = key.to_s
        @value[key] = value_class_name.to_s
        @resolved.delete(key)
      end

      # Returns the constantized value for +key+, or +default+ if absent.
      def fetch(key, default = nil)
        self[key].nil? ? default : self[key]
      end

      # Merges one or more key/value pairs into the map at runtime.
      def merge!(hash)
        hash.each { |k, v| self[k] = v }
        self
      end

      # Iterates over [key, constantized_value_class] pairs.
      def each
        return enum_for(:each) unless block_given?
        @value.each_key { |key| yield [key, self[key]] }
      end

      alias_method :each_pair, :each

      def key?(key)
        @value.key?(key.to_s)
      end

      alias_method :include?, :key?
      alias_method :has_key?, :key?

      def keys
        @value.keys
      end

      def empty?
        @value.empty?
      end

      def size
        @value.size
      end

      alias_method :length, :size

      # Returns the raw string-keyed, string-value hash (no constantization).
      # Also used for serialization via +to_h+ / +to_json+ on the parent Configuration.
      def raw_value
        @value.dup
      end

      alias_method :to_serializable_hash, :raw_value

      # Make value return self so the Configuration base accessor returns the
      # option object directly, consistent with CollectionOption.
      def value
        self
      end
    end
  end
end
