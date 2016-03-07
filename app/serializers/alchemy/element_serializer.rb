module Alchemy
  class ElementSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :position,
      :page_id,
      :page_version_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids

    def ingredients
      object.contents.collect(&:serialize)
    end

    def page_id
      object.page_version.page_id
    end
  end
end
