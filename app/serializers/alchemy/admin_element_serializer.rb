module Alchemy
  class AdminElementSerializer < ElementSerializer
    attributes :id,
      :name,
      :position,
      :page_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids,
      :display_name_with_preview_text
  end
end
