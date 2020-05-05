# frozen_string_literal: true

module Alchemy
  class EssenceSelectSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :value,
    )
  end
end
