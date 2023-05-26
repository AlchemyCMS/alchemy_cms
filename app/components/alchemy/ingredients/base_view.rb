module Alchemy
  module Ingredients
    class BaseView < ViewComponent::Base
      attr_reader :ingredient, :html_options

      delegate :alchemy, to: :helpers
      delegate :settings, :value, to: :ingredient

      # @param ingredient [Alchemy::Ingredient]
      # @param html_options [Hash] Options that will be passed to the wrapper tag.
      def initialize(ingredient, html_options: {})
        raise ArgumentError, "Ingredient missing!" if ingredient.nil?

        @ingredient = ingredient
        @html_options = html_options
      end

      def call
        value
      end

      def render?
        value.present?
      end

      private

      # Fetches value from ingredient settings and allows to merge a value on top of it
      #
      # @param key [Symbol] - The settings key you want to fetch the value from
      # @param value [Object] - A optional value that can override the setting.
      #   Normally passed as into the ingredient view.
      def settings_value(key, value: nil, default: nil)
        value.nil? ? settings.fetch(key, default) : value
      end
    end
  end
end
