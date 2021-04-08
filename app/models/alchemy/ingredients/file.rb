# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A link to a file
    #
    # Attach Alchemy::Attachment into this ingredient
    #
    class File < Alchemy::Ingredient
      ingredient_attributes(
        :css_class,
        :link_text,
        :title
      )

      related_object_alias :attachment
    end
  end
end
