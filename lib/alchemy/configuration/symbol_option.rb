# frozen_string_literal: true

module Alchemy
  class Configuration
    class SymbolOption < BaseOption
      def self.value_class
        Symbol
      end
    end
  end
end
