module Alchemy
  class EssenceAudio < ActiveRecord::Base

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

    belongs_to :attachment

  end
end
