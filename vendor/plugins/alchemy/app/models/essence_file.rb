class EssenceFile < ActiveRecord::Base
  belongs_to :file
  stampable
  
end