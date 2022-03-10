# frozen_string_literal: true

module Alchemy
  class PageSerializer < ActiveModel::Serializer
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
      :status,
      :url_path,
      :parent_id

    has_many :elements

    with_options if: -> { scope.can?(:edit_content, object) } do
      belongs_to :site
      belongs_to :language
    end
  end
end
