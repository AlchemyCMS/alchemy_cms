# == Schema Information
#
# Table name: alchemy_cells
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Alchemy
  class CellSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :page_id,
      :created_at,
      :updated_at

    has_many :elements

    def elements
      object.elements.published
    end

  end
end
