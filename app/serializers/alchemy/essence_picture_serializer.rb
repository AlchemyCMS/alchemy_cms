# frozen_string_literal: true

module Alchemy
  class EssencePictureSerializer < ActiveModel::Serializer
    attributes :id,
      :picture_id,
      :caption,
      :title,
      :alt_tag,
      :css_class,
      :link,
      :created_at,
      :updated_at

    has_one :picture

    def link
      return if object.link.blank?
      {
        url: object.link,
        css_class: object.link_class_name,
        title: object.link_title,
        target: object.link_target
      }
    end
  end
end
