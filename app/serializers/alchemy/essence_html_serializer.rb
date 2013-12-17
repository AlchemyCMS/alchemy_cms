module Alchemy
  class EssenceHtmlSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :source,
      :created_at,
      :updated_at

  end
end
