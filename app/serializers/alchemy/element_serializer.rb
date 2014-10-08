module Alchemy
  class ElementSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :position,
      :page_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids

    def ingredients
      object.contents.collect do |content|
        {
          name: content.name,
          value: content.serialized_ingredient
        }
      end
    end
  end
end
