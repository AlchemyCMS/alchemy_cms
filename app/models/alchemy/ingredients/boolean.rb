# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A boolean value
    #
    class Boolean < Alchemy::Ingredient
      def value
        ActiveRecord::Type::Boolean.new.cast(self[:value])
      end

      # The localized value
      #
      # Used by the Element#preview_text method.
      #
      def preview_text(_max_length = nil)
        return if value.nil?

        Alchemy.t(value.to_s, scope: "ingredient_values.boolean")
      end
    end
  end
end
