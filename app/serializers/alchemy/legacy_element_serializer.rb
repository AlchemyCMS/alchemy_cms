# frozen_string_literal: true

module Alchemy
  class LegacyElementSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :position,
      :page_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at

    has_many :contents
  end
end
