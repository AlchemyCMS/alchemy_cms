# frozen_string_literal: true

module Alchemy
  class EssenceDateSerializer < ActiveModel::Serializer
    attributes :id,
      :date,
      :created_at,
      :updated_at
  end
end
