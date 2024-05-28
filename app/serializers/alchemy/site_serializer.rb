# frozen_string_literal: true

module Alchemy
  class SiteSerializer < ActiveModel::Serializer
    attributes :id,
      :name
  end
end
