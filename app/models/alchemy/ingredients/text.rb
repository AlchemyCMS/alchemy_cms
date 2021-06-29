# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A simple line of text
    #
    # Optionally it can have a link
    #
    class Text < Alchemy::Ingredient
      store_accessor :data,
        :link,
        :link_target,
        :link_title,
        :link_class_name
    end
  end
end
