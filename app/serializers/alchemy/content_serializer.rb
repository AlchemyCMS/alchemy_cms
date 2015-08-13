# == Schema Information
#
# Table name: alchemy_contents
#
#  id           :integer          not null, primary key
#  name         :string
#  essence_type :string
#  essence_id   :integer
#  element_id   :integer
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer
#  updater_id   :integer
#

module Alchemy
  class ContentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :ingredient,
      :element_id,
      :position,
      :created_at,
      :updated_at,
      :settings

    has_one :essence, polymorphic: true

    def ingredient
      object.serialized_ingredient
    end
  end
end
