class WaAtomPicture < ActiveRecord::Base
  stampable :stamper_class_name => :wa_user
  belongs_to :wa_image
  before_save :replace_newlines
  
  def replace_newlines
    caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
  end
  
  def content
    self.wa_image
  end
  
end
