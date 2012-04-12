module Alchemy
  class EssenceVideo < ActiveRecord::Base

    attr_accessible(
      :width,
      :height,
      :allow_fullscreen,
      :auto_play,
      :show_navigation
    )

    acts_as_essence(
      :ingredient_column => :attachment,
      :preview_text_method => :name
    )

    belongs_to :attachment

  end
end
