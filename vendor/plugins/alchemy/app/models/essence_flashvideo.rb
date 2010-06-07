class EssenceFlashvideo < ActiveRecord::Base
  belongs_to :file
  stampable
  
end