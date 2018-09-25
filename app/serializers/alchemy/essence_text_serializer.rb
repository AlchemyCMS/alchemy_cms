# frozen_string_literal: true

module Alchemy
  class EssenceTextSerializer < ActiveModel::Serializer
    attributes :id,
      :body,
      :link,
      :created_at,
      :updated_at

    def link
      return if object.link.blank?
      {
        url: object.link,
        title: object.link_title,
        css_class: object.link_class_name,
        target: object.link_target
      }
    end
  end
end
