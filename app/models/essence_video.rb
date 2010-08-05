class EssenceVideo < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
end