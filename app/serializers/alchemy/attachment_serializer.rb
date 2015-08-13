# == Schema Information
#
# Table name: alchemy_attachments
#
#  id              :integer          not null, primary key
#  name            :string
#  file_name       :string
#  file_mime_type  :string
#  file_size       :integer
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cached_tag_list :text
#  file_uid        :string
#

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
