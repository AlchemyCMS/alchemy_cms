# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A link to a menu node
    #
    # Assign Alchemy::Node to this ingredient
    #
    class Node < Alchemy::Ingredient
      related_object_alias :node
    end
  end
end
