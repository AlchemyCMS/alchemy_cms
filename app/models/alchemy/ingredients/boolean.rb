# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A boolean value
    #
    class Boolean < Alchemy::Ingredient
      def value
        ActiveRecord::Type::Boolean.new.cast(self[:value])
      end
    end
  end
end
