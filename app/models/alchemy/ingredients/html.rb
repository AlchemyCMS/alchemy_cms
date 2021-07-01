# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A HTML string
    #
    class Html < Alchemy::Ingredient
      # The first 30 escaped characters from value
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        ::CGI.escapeHTML(value.to_s)[0..max_length - 1]
      end
    end
  end
end
