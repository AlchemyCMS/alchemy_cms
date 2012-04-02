module Alchemy
  class EssenceFlash < ActiveRecord::Base

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

  end
end
