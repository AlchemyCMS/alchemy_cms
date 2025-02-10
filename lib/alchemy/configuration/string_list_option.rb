# frozen_string_literal: true

require "alchemy/configuration/list_option"

module Alchemy
  class Configuration
    class StringListOption < ListOption
      def self.item_class
        String
      end
    end
  end
end
