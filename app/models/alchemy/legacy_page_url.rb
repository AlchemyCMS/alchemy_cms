class Alchemy::LegacyPageUrl < ActiveRecord::Base
  attr_accessible :page, :page_id, :urlname
  belongs_to :page, class_name: 'Alchemy::Page'

  validates_presence_of [:urlname, :page_id]
end