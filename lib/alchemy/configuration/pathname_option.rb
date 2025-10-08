# frozen_string_literal: true

require "alchemy/configuration/base_option"
module Alchemy
  class Configuration
    class PathnameOption < BaseOption
      def self.value_class
        Pathname
      end
    end
  end
end
