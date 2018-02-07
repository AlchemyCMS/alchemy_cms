# frozen_string_literal: true

module Alchemy
  class EssenceFileSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :title,
      :css_class,
      :attachment_id
    )

    has_one :attachment
  end
end
