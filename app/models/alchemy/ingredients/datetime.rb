# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A datetime value
    #
    class Datetime < Alchemy::Ingredient
      allow_settings %i[date_format]

      def value
        ActiveRecord::Type::DateTime.new.cast(self[:value])
      end

      # Returns localized date for the Element#preview_text method.
      def preview_text(_maxlength = nil)
        return "" unless value

        ::I18n.l(value, format: :'alchemy.ingredient_date')
      end
    end
  end
end
