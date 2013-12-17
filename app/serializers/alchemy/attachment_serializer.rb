module Alchemy
  class AttachmentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :file_name,
      :file_mime_type,
      :file_size,
      :tag_list,
      :created_at,
      :updated_at

  end
end
