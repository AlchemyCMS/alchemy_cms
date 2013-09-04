require 'alchemy/essence'

# Provides a select box that stores string values.
module Alchemy
  class EssenceSelect < ActiveRecord::Base
    acts_as_essence ingredient_column: 'value'
  end
end
