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

  validates_presence_of [:urlname, :page_id]
end
