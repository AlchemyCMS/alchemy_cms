# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class ListOption < BaseOption
      def self.item_class
        raise NotImplementedError
      end

      private

      def validate(value)
        unless value.is_a?(Array) && value.all? { _1.is_a?(self.class.item_class) }
          raise TypeError, "#{@name} must be an Array of #{self.class.item_class.name.downcase.pluralize}, given #{value.inspect}"
        end
        value
      end
    end
  end
end
