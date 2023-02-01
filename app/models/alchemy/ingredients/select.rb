# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A text value from a select box
    #
    class Select < Alchemy::Ingredient
      allow_settings %i[display_inline select_values]
    end
  end
end
