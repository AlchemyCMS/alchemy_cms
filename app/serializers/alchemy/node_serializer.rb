# frozen_string_literal: true

module Alchemy
  class NodeSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :lft,
      :rgt,
      :url,
      :parent_id
  end
end
