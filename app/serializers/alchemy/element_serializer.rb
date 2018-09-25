# frozen_string_literal: true

module Alchemy
  class ElementSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :position,
      :page_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids

    has_many :nested_elements

    def ingredients
      object.contents.collect(&:serialize)
    end
  end
end
