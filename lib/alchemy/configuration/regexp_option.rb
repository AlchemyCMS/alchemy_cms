# frozen_string_literal: true

module Alchemy
  class Configuration
    class RegexpOption < BaseOption
      def self.value_class
        Regexp
      end
    end
  end
end
