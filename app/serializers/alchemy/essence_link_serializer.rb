module Alchemy
  class EssenceLinkSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :link,
      :link_title,
      :link_target,
      :link_class_name,
      :created_at,
      :updated_at

  end
end
