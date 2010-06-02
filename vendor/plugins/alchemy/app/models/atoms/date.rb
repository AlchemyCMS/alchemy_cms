class WaAtomDate < ActiveRecord::Base
  stampable :stamper_class_name => :wa_user
  def content
    self.date
  end
  
end