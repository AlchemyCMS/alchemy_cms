class AtomFile < ActiveRecord::Base
  
  belongs_to :file
  
  stampable
  
  def content
    self.file
  end
  
end