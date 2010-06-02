class AtomDate < ActiveRecord::Base
  
  stampable
  
  def content
    self.date
  end
  
end