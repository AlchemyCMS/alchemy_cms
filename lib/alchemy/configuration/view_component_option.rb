# frozen_string_literal: true

module Alchemy
  class Configuration
    # Configuration option for ViewComponents.
    # Validates that the value is a subclass of +ViewComponent::Base+.
    class ViewComponentOption < BaseOption
      def self.value_class
        ViewComponent::Base
      end
    end
  end
end
