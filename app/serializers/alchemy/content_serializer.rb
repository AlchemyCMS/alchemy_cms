module Alchemy
  class ContentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :essence_type,
      :essence_id,
      :element_id,
      :position,
      :created_at,
      :updated_at,
      :essence,
      :ingredient

  end
end
