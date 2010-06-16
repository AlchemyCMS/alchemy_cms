class EssenceAudio < ActiveRecord::Base
  belongs_to :attachement
  stampable
  
end
