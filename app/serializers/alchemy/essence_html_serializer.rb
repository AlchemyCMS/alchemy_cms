# == Schema Information
#
# Table name: alchemy_essence_htmls
#
#  id         :integer          not null, primary key
#  source     :text
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Alchemy
  class EssenceHtmlSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :source,
      :created_at,
      :updated_at

  end
end
