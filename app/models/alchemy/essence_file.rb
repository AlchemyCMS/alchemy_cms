module Alchemy
  class EssenceFile < ActiveRecord::Base

    attr_accessible :title, :css_class, :attachment_id

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

    belongs_to :attachment

  end
end
