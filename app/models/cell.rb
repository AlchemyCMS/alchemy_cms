class Cell < ActiveRecord::Base
  
  belongs_to :page
  has_many :elements, :dependent => :destroy, :order => :position
  
end
