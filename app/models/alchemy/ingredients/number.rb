# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A number
    #
    # Either a decimal or integer number
    #
    class Number < Alchemy::Ingredient
      allow_settings %i[
        input_type
        step
        min
        max
        unit
      ]
    end
  end
end
