# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A URL
    #
    class Link < Alchemy::Ingredient
      store_accessor :data,
        :link_class_name,
        :link_target,
        :link_title

      alias_method :link, :value
    end
  end
end
