# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      autoload :Base, "alchemy/liquid/drops/base"
      autoload :ElementDrop, "alchemy/liquid/drops/element_drop"
      autoload :IngredientDrop, "alchemy/liquid/drops/ingredient_drop"
      autoload :IngredientsDrop, "alchemy/liquid/drops/ingredients_drop"
      autoload :NodeDrop, "alchemy/liquid/drops/node_drop"
      autoload :PageDrop, "alchemy/liquid/drops/page_drop"
    end
  end
end
