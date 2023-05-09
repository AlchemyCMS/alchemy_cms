module Alchemy
  module Ingredients
    class RichtextView < BaseView
      attr_reader :plain_text

      # @param ingredient [Alchemy::Ingredient]
      # @param plain_text [Boolean] (false) Whether to show as plain text or with markup
      def initialize(ingredient, plain_text: nil)
        super(ingredient)
        @plain_text = plain_text.nil? ? ingredient.settings.fetch(:plain_text, false) : plain_text
      end

      def call
        if plain_text
          ingredient.stripped_body
        else
          value.to_s.html_safe
        end
      end
    end
  end
end
