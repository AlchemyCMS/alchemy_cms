# frozen_string_literal: true

module Alchemy
  class Configuration
    class StringOption < BaseOption
      def self.value_class
        String
      end
    end
  end
end
