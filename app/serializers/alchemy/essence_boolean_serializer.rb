# frozen_string_literal: true

module Alchemy
  class EssenceBooleanSerializer < ActiveModel::Serializer
    attributes :id,
      :value,
      :created_at,
      :updated_at
  end
end
