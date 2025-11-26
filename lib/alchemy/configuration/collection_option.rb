# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class CollectionOption < BaseOption
      include Enumerable

      def self.value_class
        Enumerable
      end

      attr_reader :collection_class, :item_class, :item_args

      def initialize(value:, name:, item_type:, collection_class: Array, **args)
        @collection_class = collection_class
        @item_class = get_item_class(item_type)
        @item_args = args
        value = [] if value.nil?
        collection = @collection_class.new(value.map { |value| to_item(value) })
        super(value: collection, name: name)
      rescue ConfigurationError => configuration_error
        raise ConfigurationError.new(name, configuration_error.value, configuration_error.allowed_classes)
      end

      def value
        self
      end

      def <<(value)
        @value << to_item(value)
      end
      alias_method(:add, :<<)

      def concat(values)
        values.each do |value|
          add(value)
        end
      end

      def delete(value)
        @value.delete to_item(value)
      end

      delegate :join, :[], to: :to_a

      delegate :clear, :empty?, to: :@value

      def each(&block)
        @value.each do |option|
          yield option.value
        end
      end

      def to_serializable_array
        to_a.map do |item|
          item.respond_to?(:to_h) ? item.to_h : item
        end
      end

      private

      def to_item(value)
        @item_class.new(value: value, name: "#{name}_item", **item_args)
      end

      def get_item_class(item_type)
        "Alchemy::Configuration::#{item_type.to_s.classify}Option".constantize
      end
    end
  end
end
