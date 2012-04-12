module Alchemy
  class EssenceAudio < ActiveRecord::Base

    attr_accessible :width, :height, :show_eq, :show_navigation

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

    belongs_to :attachment

  end
end
