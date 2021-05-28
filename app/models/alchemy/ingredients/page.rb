# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A link to a page
    #
    # Assign Alchemy::Page to this ingredient
    #
    class Page < Alchemy::Ingredient
      related_object_alias :page, class_name: "Alchemy::Page"

      # The first 30 characters of page name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        page&.name.to_s[0..max_length - 1]
      end
    end
  end
end
