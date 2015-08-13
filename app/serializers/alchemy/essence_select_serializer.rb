# == Schema Information
#
# Table name: alchemy_essence_selects
#
#  id         :integer          not null, primary key
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :integer
#  updater_id :integer
#

module Alchemy
  class EssenceSelectSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :value,
      :created_at,
      :updated_at

  end
end
