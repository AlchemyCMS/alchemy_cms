class EssencePicture < ActiveRecord::Base
  stampable
  belongs_to :image
  before_save :replace_newlines
  
  def replace_newlines
    return nil if caption.nil?
    caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
  end
  
end
