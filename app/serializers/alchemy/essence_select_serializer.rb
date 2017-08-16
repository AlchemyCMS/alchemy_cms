# frozen_string_literal: true

module Alchemy
  class EssenceSelectSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :value,
      :created_at,
      :updated_at
  end
end
