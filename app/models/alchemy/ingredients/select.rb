# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A text value from a select box
    #
    class Select < Alchemy::Ingredient
      allow_settings %i[display_inline select_values multiple]

      serialize :value, coder: JSON

      # Override value getter to handle multiple selection
      def value
        if multiple?
          val = super
          val.is_a?(Array) ? val : []
        else
          super
        end
      end

      # Override value setter to handle multiple selection
      def value=(new_value)
        if multiple?
          # Handle array of values - compact_blank removes nil and empty strings
          super(Array(new_value).compact_blank)
        else
          super
        end
      end

      # Check if multiple selection is enabled in settings
      def multiple?
        settings[:multiple] == true
      end
    end
  end
end
