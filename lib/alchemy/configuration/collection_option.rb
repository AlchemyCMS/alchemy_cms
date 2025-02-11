# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class CollectionOption < BaseOption
      attr_reader :collection_class
      attr_reader :item_class

      def initialize(value:, name:, item_class:, collection_class: Array, **args)
        @collection_class = collection_class
        @item_class = item_class
        value = collection_class.new(value)
        super
      end

      private

      def validate(value)
        unless value.is_a?(collection_class) && value.all? { _1.is_a?(item_class) }
          raise TypeError, "#{@name} must be a #{collection_class} of #{item_class.name.downcase.pluralize}, given #{value.inspect}"
        end
        value
      end
    end
  end
end
