# == Schema Information
#
# Table name: alchemy_essence_richtexts
#
#  id            :integer          not null, primary key
#  body          :text
#  stripped_body :text
#  public        :boolean
#  creator_id    :integer
#  updater_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Alchemy
  class EssenceRichtextSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :body,
      :stripped_body,
      :created_at,
      :updated_at

  end
end
