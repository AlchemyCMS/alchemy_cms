# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class ClassOption < BaseOption
      def self.value_class
        String
      end

      def value = @value.constantize
    end
  end
end
