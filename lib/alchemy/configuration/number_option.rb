# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class NumberOption < BaseOption
      def self.value_class
        Numeric
      end
    end
  end
end
