# Stores boolean values.
# Provides a checkbox in the editor views.
module Alchemy
  class EssenceBoolean < ActiveRecord::Base
    acts_as_essence :ingredient_column => :value
    attr_accessible :value
  end
end
