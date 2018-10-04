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

    with_options if: :can_manage? do
      attribute :folded
      attribute :public
      attribute :preview_text
      attribute :display_name
    end

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

    def can_manage?
      scope.can?(:manage, object)
    end
  end
end
