# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A URL
    #
    class Link < Alchemy::Ingredient
      self.ingredient_attributes = %i[
        link_class_name
        link_target
        link_title
      ]
    end
  end
end
