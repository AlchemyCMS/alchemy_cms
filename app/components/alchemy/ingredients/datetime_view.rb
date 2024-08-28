module Alchemy
  module Ingredients
    class DatetimeView < BaseView
      attr_reader :date_format

      # @param ingredient [Alchemy::Ingredient]
      # @param date_format [String] The date format to use. Use either a strftime format string, a I18n format symbol or "rfc822".
      def initialize(ingredient, date_format: nil, html_options: {})
        super(ingredient)
        @date_format = settings_value(:date_format, value: date_format)
      end

      def call
        datetime = ingredient.value.in_time_zone(Rails.application.config.time_zone)
        if date_format == "rfc822"
          datetime.to_fs(:rfc822)
        else
          ::I18n.l(datetime, format: date_format)
        end.html_safe
      end
    end
  end
end
