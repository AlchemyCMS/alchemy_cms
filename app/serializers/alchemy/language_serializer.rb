# frozen_string_literal: true

module Alchemy
  class LanguageSerializer < ActiveModel::Serializer
    attributes :id,
      :name
  end
end
