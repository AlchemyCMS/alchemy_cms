module Alchemy
  class PictureDescription < ActiveRecord::Base
    belongs_to :picture, class_name: "Alchemy::Picture"
    belongs_to :language, class_name: "Alchemy::Language"

    validates_uniqueness_of :picture_id, scope: :language_id
  end
end
