class Cell < ActiveRecord::Base
  
  belongs_to :page
  has_many :elements, :dependend => :destroy, :order => :position
  
end
