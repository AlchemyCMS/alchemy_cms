# == Schema Information
#
# Table name: alchemy_essence_dates
#
#  id         :integer          not null, primary key
#  date       :datetime
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Alchemy
  class EssenceDateSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :date,
      :created_at,
      :updated_at

  end
end
