# frozen_string_literal: true

module Alchemy
  class NodeSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :lft,
      :rgt,
      :url,
      :parent_id

    has_many :ancestors, record_type: :node, serializer: self
  end
end
