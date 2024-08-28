module Alchemy
  module Ingredients
    class DatetimeView < BaseView
      attr_reader :date_format

      # @param ingredient [Alchemy::Ingredient]
      # @param date_format [String] The date format to use. Use either a strftime format string, a I18n format symbol or "rfc822". Defaults to "time.formats.alchemy.default".
      def initialize(ingredient, date_format: :"alchemy.default", html_options: {})
        super(ingredient)
        @date_format = settings_value(:date_format, value: date_format)
      end

      def call
        if date_format == "rfc822"
          ingredient.value.to_fs(:rfc822)
        else
          ::I18n.l(ingredient.value, format: date_format)
        end.html_safe
      end
    end
  end
end
