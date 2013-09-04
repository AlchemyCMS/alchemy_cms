require 'alchemy/essence'

module Alchemy
  class EssenceLink < ActiveRecord::Base
    acts_as_essence ingredient_column: 'link'
  end
end
