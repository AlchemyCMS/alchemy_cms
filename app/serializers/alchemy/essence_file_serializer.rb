module Alchemy
  class EssenceFileSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :title,
      :css_class

    has_one :attachment

  end
end
