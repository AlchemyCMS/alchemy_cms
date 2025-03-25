# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class CollectionOption < BaseOption
      include Enumerable

      def self.value_class
        Enumerable
      end

      attr_reader :collection_class, :item_class

      def initialize(value:, name:, item_type:, collection_class: Array, **args)
        @collection_class = collection_class
        @item_class = get_item_class(item_type)
        value = [] if value.nil?
        collection = @collection_class.new(value.map { |value| to_item(value) })
        super(value: collection, name: name)
      rescue ConfigurationError => configuration_error
        raise ConfigurationError.new(name, configuration_error.value, configuration_error.expected_type)
      end

      def value
        self
      end

      def <<(value)
        @value << to_item(value)
      end
      alias_method(:add, :<<)

      def [](index)
        to_a[index]
      end

      def concat(values)
        values.each do |value|
          add(value)
        end
      end

      delegate :join, :[], to: :to_a

      delegate :clear, :empty?, to: :@value

      def each(&block)
        @value.each do |option|
          yield option.value
        end
      end

      private

      def to_item(value)
        @item_class.new(value: value, name: "#{name}_item")
      end

      def get_item_class(item_type)
        "Alchemy::Configuration::#{item_type.to_s.classify}Option".constantize
      end
    end
  end
end
