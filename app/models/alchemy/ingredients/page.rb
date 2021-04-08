# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A link to a page
    #
    # Assign Alchemy::Page to this ingredient
    #
    class Page < Alchemy::Ingredient
      related_object_alias :page
    end
  end
end
