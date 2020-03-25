# frozen_string_literal: true

module Alchemy
  class ContentSerializer < ActiveModel::Serializer
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
