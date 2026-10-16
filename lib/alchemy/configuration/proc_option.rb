# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class ProcOption < BaseOption
      def self.value_class
        Proc
      end
    end
  end
end
