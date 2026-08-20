# == Schema Information
#
# Table name: alchemy_picture_descriptions
#
#  id          :integer          not null, primary key
#  text        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer          not null
#  picture_id  :integer          not null
#
# Indexes
#
#  alchemy_picture_descriptions_on_picture_id_and_language_id  (picture_id,language_id) UNIQUE
#  index_alchemy_picture_descriptions_on_language_id           (language_id)
#  index_alchemy_picture_descriptions_on_picture_id            (picture_id)
#
# Foreign Keys
#
#  language_id  (language_id => alchemy_languages.id)
#  picture_id   (picture_id => alchemy_pictures.id)
#
module Alchemy
  class PictureDescription < ActiveRecord::Base
    belongs_to :picture, class_name: "Alchemy::Picture"
    belongs_to :language, class_name: "Alchemy::Language"

    validates_uniqueness_of :picture_id, scope: :language_id
  end
end
