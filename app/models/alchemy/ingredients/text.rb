# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A simple line of text
    #
    # Optionally it can have a link
    #
    class Text < Alchemy::Ingredient
      def link
        data[:link]
      end

      def link_target
        data[:link_target]
      end

      def link_title
        data[:link_title]
      end

      def link_class_name
        data[:link_class_name]
      end
    end
  end
end
