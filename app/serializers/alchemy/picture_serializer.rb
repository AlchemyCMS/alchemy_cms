# == Schema Information
#
# Table name: alchemy_pictures
#
#  id                :integer          not null, primary key
#  name              :string
#  image_file_name   :string
#  image_file_width  :integer
#  image_file_height :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#  upload_hash       :string
#  cached_tag_list   :text
#  image_file_uid    :string
#  image_file_size   :integer
#  picture_id        :integer
#

module Alchemy
  class PictureSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :image_file_name,
      :image_file_width,
      :image_file_height,
      :image_file_size,
      :tag_list,
      :created_at,
      :updated_at

  end
end
