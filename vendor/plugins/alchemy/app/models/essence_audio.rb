class EssenceAudio < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
end
