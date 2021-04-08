# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A URL
    #
    class Link < Alchemy::Ingredient
      ingredient_attributes(
        :link_class_name,
        :link_target,
        :link_title,
      )
    end
  end
end
