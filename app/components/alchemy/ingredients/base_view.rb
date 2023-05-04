module Alchemy
  module Ingredients
    class BaseView < ViewComponent::Base
      attr_reader :ingredient, :html_options

      delegate :alchemy, to: :helpers
      delegate :value, to: :ingredient

      # @param ingredient [Alchemy::Ingredient]
      # @param html_options [Hash] Options that will be passed to the wrapper tag.
      def initialize(ingredient, html_options: {})
        raise ArgumentError, "Ingredient missing!" if ingredient.nil?

        @ingredient = ingredient
        @html_options = html_options
      end
    end
  end
end
