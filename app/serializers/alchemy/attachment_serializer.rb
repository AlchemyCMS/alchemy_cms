# frozen_string_literal: true

module Alchemy
  class AttachmentSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :file_name,
      :file_mime_type,
      :file_size,
      :icon_css_class,
      :tag_list,
      :created_at,
      :updated_at
  end
end
