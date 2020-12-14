# frozen_string_literal: true

module Alchemy
  class ElementSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :position,
      :page_id,
      :page_version_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids,
      :dom_id,
      :display_name

    has_many :nested_elements

    def ingredients
      object.contents.collect(&:serialize)
    end

    def display_name
      object.display_name_with_preview_text
    end

    def page_id
      object.page.id
    end
  end
end
