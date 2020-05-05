# frozen_string_literal: true

module Alchemy
  class EssenceDateSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :date,
    )
  end
end
