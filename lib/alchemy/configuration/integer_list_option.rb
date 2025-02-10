# frozen_string_literal: true

require "alchemy/configuration/list_option"

module Alchemy
  class Configuration
    class IntegerListOption < ListOption
      def self.item_class
        Integer
      end
    end
  end
end
