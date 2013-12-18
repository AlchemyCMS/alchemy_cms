module Alchemy
  class PageSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :urlname,
      :page_layout,
      :title,
      :language_code,
      :meta_keywords,
      :meta_description,
      :tag_list,
      :created_at,
      :updated_at,
      :status

    has_many :elements, :cells

    def elements
      if object.has_cells?
        object.elements.not_in_cell.published
      else
        object.elements.published
      end
    end

  end
end
