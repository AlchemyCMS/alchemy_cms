class EssenceFlash < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
end
