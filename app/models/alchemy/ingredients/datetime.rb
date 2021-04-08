# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A datetime value
    #
    class Datetime < Alchemy::Ingredient
      def value
        ActiveRecord::Type::DateTime.new.cast(self[:value])
      end
    end
  end
end
