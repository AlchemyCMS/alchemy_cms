# == Schema Information
#
# Table name: alchemy_essence_booleans
#
#  id         :integer          not null, primary key
#  value      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :integer
#  updater_id :integer
#

module Alchemy
  class EssenceBooleanSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :value,
      :created_at,
      :updated_at

  end
end
