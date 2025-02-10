# frozen_string_literal: true

require "alchemy/configuration/base_option"
module Alchemy
  class Configuration
    class IntegerOption < BaseOption
      def self.value_class
        Integer
      end
    end
  end
end
