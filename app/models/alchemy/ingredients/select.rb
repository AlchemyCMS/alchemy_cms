# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A text value from a select box
    #
    class Select < Alchemy::Ingredient
      allow_settings %i[display_inline select_values]
      allow_settings %i[display_inline select_values multiple]

      serialize :value, coder: JSON

      # Override value getter to handle multiple selection
      def value
        val = self[:value] || []
        multiple? ? val : val.first
      end

      # Override value setter to handle multiple selection
      def value=(new_value)
        super(Array(new_value).compact_blank)
      end

      # Check if multiple selection is enabled in settings
      def multiple?
        settings[:multiple] == true
      end
    end
  end
end
