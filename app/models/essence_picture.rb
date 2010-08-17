class EssencePicture < ActiveRecord::Base
  stampable
  belongs_to :picture
  before_save :replace_newlines
  
  def replace_newlines
    return nil if caption.nil?
    caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
  end
  
  # Returns self.picture.name for the Element#preview_text method.
  def preview_text
    return "" if picture.blank?
    picture.name.to_s
  end
  
end
