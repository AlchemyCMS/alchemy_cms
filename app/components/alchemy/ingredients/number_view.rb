module Alchemy
  module Ingredients
    class NumberView < BaseView
      def initialize(ingredient, options = {})
        super(ingredient)
        @options = {
          units: {
            unit: settings_value(:unit, value: options[:unit])
          }.merge(options[:units] || {})
        }
      end

      def call
        number_to_human(value, @options)
      end
    end
  end
end
