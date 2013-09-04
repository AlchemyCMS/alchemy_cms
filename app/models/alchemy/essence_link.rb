module Alchemy
  class EssenceLink < ActiveRecord::Base

    acts_as_essence(
      :ingredient_column => :link
    )

    attr_accessible :link, :link_title, :link_class_name, :link_target

  end
end
