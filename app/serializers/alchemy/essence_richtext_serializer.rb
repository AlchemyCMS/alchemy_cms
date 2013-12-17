module Alchemy
  class EssenceRichtextSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :body,
      :stripped_body,
      :created_at,
      :updated_at

  end
end
