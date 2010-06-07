class EssenceAudio < ActiveRecord::Base
  belongs_to :file
  stampable
  
end
