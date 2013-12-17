module Alchemy
  class EssenceDateSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :date,
      :created_at,
      :updated_at

  end
end
