# frozen_string_literal: true

module Alchemy
  class AttachmentSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :file_name,
      :file_mime_type,
      :file_size,
      :tag_list,
      :created_at,
      :updated_at

    attribute :icon_css_class, if: -> { scope.can?(:manage, object) }
  end
end
