module Alchemy
  module Ingredients
    class SelectView < BaseView
      def call
        if ingredient.multiple? && value.is_a?(Array)
          # Join array values with comma and space for display
          value.join(", ").html_safe
        else
          super
        end
      end
    end
  end
end
