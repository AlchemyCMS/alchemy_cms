class EssenceVideo < ActiveRecord::Base
  belongs_to :file
  stampable
  
end