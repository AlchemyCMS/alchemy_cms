module Alchemy
  module Ingredients
    class RichtextView < BaseView
      attr_reader :plain_text

      delegate :sanitizer_settings, to: :ingredient

      # @param ingredient [Alchemy::Ingredient]
      # @param plain_text [Boolean] (false) Whether to show as plain text or with markup
      def initialize(ingredient, plain_text: nil, html_options: {})
        super(ingredient)
        @plain_text = settings_value(:plain_text, value: plain_text, default: false)
      end

      def call
        if plain_text
          ingredient.stripped_body
        elsif sanitizer_settings.present?
          sanitize(value.to_s, **sanitizer_settings)
        else
          value.to_s.html_safe
        end.html_safe
      end
    end
  end
end
