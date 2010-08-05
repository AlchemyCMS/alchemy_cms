class EssenceFile < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
end