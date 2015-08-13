# == Schema Information
#
# Table name: alchemy_picture_assignments
#
#  id              :integer          not null, primary key
#  picture_id      :integer
#  assignable_id   :integer
#  assignable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#

module Alchemy
  class PictureAssignment < ActiveRecord::Base
    belongs_to :assignable, polymorphic: true
    belongs_to :picture
    has_one :picture_style, dependent: :destroy

    after_create :create_picture_style
  end
end
