# == Schema Information
#
# Table name: alchemy_pages
#
#  id               :integer          not null, primary key
#  name             :string
#  urlname          :string
#  title            :string
#  language_code    :string
#  language_root    :boolean
#  page_layout      :string
#  meta_keywords    :text
#  meta_description :text
#  lft              :integer
#  rgt              :integer
#  parent_id        :integer
#  depth            :integer
#  visible          :boolean          default(FALSE)
#  public           :boolean          default(FALSE)
#  locked           :boolean          default(FALSE)
#  locked_by        :integer
#  restricted       :boolean          default(FALSE)
#  robot_index      :boolean          default(TRUE)
#  robot_follow     :boolean          default(TRUE)
#  sitemap          :boolean          default(TRUE)
#  layoutpage       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :integer
#  updater_id       :integer
#  language_id      :integer
#  cached_tag_list  :text
#  published_at     :datetime
#

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
