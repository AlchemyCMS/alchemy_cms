module Alchemy
  module Ingredients
    class SelectView < BaseView
      def call
        if ingredient.multiple? && value.is_a?(Array)
          value.to_sentence
        else
          super
        end
      end
    end
  end
end
