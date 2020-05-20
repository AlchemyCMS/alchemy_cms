# frozen_string_literal: true

module Alchemy
  class EssenceHtmlSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :source,
    )
  end
end
