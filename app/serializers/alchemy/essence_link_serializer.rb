# == Schema Information
#
# Table name: alchemy_essence_links
#
#  id              :integer          not null, primary key
#  link            :string
#  link_title      :string
#  link_target     :string
#  link_class_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#

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
