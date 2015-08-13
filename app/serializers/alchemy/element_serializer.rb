# == Schema Information
#
# Table name: alchemy_elements
#
#  id                :integer          not null, primary key
#  name              :string
#  position          :integer
#  page_id           :integer
#  public            :boolean          default(TRUE)
#  folded            :boolean          default(FALSE)
#  unique            :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#  cell_id           :integer
#  cached_tag_list   :text
#  parent_element_id :integer
#

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
      object.contents.collect(&:serialize)
    end
  end
end
