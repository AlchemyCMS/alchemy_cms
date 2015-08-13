# == Schema Information
#
# Table name: alchemy_essence_texts
#
#  id              :integer          not null, primary key
#  body            :text
#  link            :string
#  link_title      :string
#  link_class_name :string
#  public          :boolean          default(FALSE)
#  link_target     :string
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Alchemy
  class EssenceTextSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :body,
      :link,
      :created_at,
      :updated_at

    def link
      return if object.link.blank?
      {
        url: object.link,
        title: object.link_title,
        css_class: object.link_class_name,
        target: object.link_target
      }
    end

  end
end
