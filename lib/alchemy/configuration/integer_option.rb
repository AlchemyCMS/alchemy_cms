# frozen_string_literal: true

module Alchemy
  class Configuration
    class IntegerOption
      def initialize(value:, **_args)
        @value = value
      end

      attr_reader :value
    end
  end
end
