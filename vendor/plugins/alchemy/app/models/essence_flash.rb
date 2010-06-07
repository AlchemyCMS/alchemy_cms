class EssenceFlash < ActiveRecord::Base
  belongs_to :file
  stampable
  
end
