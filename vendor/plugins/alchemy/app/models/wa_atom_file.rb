class WaAtomFile < ActiveRecord::Base
  belongs_to :wa_file
  stampable :stamper_class_name => :wa_user
  def content
    self.wa_file
  end
  
end