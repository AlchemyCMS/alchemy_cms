class EssencePicture < ActiveRecord::Base
  stampable
  belongs_to :picture
  before_save :replace_newlines
  
  def replace_newlines
    return nil if caption.nil?
    caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
  end
  
  # Returns self.picture.name for the Element#preview_text method.
  def preview_text(foo=nil)
    return "" if picture.blank?
    picture.name.to_s
  end
  
  # Returns self.picture. Used for Content#ingredient method.
  def ingredient
    self.picture
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.link_class_name = params['link_class_name']
    self.open_link_in_new_window = (params['open_link_in_new_window'] == '1')
    self.link = params['link']
    self.link_title = params['link_title']
    self.picture_id = params['picture_id']
    self.save!
  end
  
end
