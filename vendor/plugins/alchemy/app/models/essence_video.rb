class EssenceVideo < ActiveRecord::Base
  belongs_to :attachement
  stampable
  
end