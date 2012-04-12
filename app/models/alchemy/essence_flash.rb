module Alchemy
  class EssenceFlash < ActiveRecord::Base

    attr_accessible :width, :height, :player_version

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

  end
end
