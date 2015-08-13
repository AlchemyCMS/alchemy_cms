# == Schema Information
#
# Table name: alchemy_essence_files
#
#  id            :integer          not null, primary key
#  attachment_id :integer
#  title         :string
#  css_class     :string
#  creator_id    :integer
#  updater_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  link_text     :string
#

module Alchemy
  class EssenceFileSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :title,
      :css_class

    has_one :attachment

  end
end
