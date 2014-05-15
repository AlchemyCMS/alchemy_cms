# == Schema Information
#
# Table name: alchemy_legacy_page_urls
#
#  id         :integer          not null, primary key
#  urlname    :string(255)      not null
#  page_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Alchemy::LegacyPageUrl < ActiveRecord::Base
  belongs_to :page, class_name: 'Alchemy::Page'

  validates :page_id,
    presence: true
  validates :urlname,
    presence: true,
    format: {with: /\A[:\.\w\-+_\/\?&%;=]*\z/}
end
