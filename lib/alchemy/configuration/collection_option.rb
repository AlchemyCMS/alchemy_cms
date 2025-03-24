# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class CollectionOption < BaseOption
      def self.value_class
        Enumerable
      end

      attr_reader :collection_class
      attr_reader :item_option_class

      def initialize(value:, name:, item_type:, collection_class: Array, **args)
        @collection_class = collection_class
        @item_option_class = "Alchemy::Configuration::#{item_type.to_s.classify}Option".constantize
        super
        @value = value.map { @item_option_class.new(value: _1, name: "#{name}_item") }
      end

      def value
        @collection_class.new(@value.map(&:value))
      end

      def validate(value)
        super
        value.each { item_option_class.new(value: _1, name: "#{name}_item") }
      rescue ConfigurationError => configuration_error
        raise ConfigurationError.new(name, configuration_error.value, configuration_error.expected_type)
      end
    end
  end
end
