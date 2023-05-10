module Alchemy
  module Ingredients
    class DatetimeView < BaseView
      # @param ingredient [Alchemy::Ingredient]
      # @param date_format [String] The date format to use. Use either a strftime format string, a I18n format symbol or "rfc822".
      def initialize(ingredient, date_format: nil)
        super(ingredient)
        @date_format = date_format
      end

      def call
        if date_format == "rfc822"
          ingredient.value.to_s(:rfc822)
        else
          ::I18n.l(ingredient.value, format: date_format)
        end
      end

      private

      def date_format
        @date_format || ingredient.settings[:date_format]
      end
    end
  end
end
