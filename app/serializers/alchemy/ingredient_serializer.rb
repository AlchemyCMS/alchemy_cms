# frozen_string_literal: true

module Alchemy
  class IngredientSerializer < ActiveModel::Serializer
    attributes :id,
      :role,
      :value,
      :element_id,
      :data
  end
end
