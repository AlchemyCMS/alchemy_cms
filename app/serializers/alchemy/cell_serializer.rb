# frozen_string_literal: true

module Alchemy
  class CellSerializer < ActiveModel::Serializer
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
