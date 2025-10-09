# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class BooleanOption < BaseOption
      def allowed_classes
        [TrueClass, FalseClass]
      end
    end
  end
end
