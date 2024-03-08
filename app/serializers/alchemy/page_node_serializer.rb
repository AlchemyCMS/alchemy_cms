# frozen_string_literal: true

module Alchemy
  class PageNodeSerializer < ActiveModel::Serializer
    attributes :id,
      :url_path,
      :parent_id
  end
end
