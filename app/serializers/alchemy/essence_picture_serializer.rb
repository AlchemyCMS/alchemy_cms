# == Schema Information
#
# Table name: alchemy_essence_pictures
#
#  id              :integer          not null, primary key
#  caption         :string
#  title           :string
#  alt_tag         :string
#  link            :string
#  link_class_name :string
#  link_title      :string
#  css_class       :string
#  link_target     :string
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Alchemy
  class EssencePictureSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :picture_id,
      :caption,
      :title,
      :alt_tag,
      :css_class,
      :link,
      :created_at,
      :updated_at

    has_one :picture

    def link
      return if object.link.blank?
      {
        url: object.link,
        css_class: object.link_class_name,
        title: object.link_title,
        target: object.link_target
      }
    end

  end
end
