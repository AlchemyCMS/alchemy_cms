class Alchemy::LegacyPageUrl < ActiveRecord::Base
  belongs_to :page, class_name: 'Alchemy::Page'

  validates_presence_of [:urlname, :page_id]
end