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
