class EssenceText < ActiveRecord::Base
  
  acts_as_ferret(:fields => {:body => {:store => :yes}}, :remote => false) if Alchemy::Configuration.parameter(:ferret) == true
  stampable
  before_save :check_ferret_indexing if Alchemy::Configuration.parameter(:ferret) == true
  
  # Returns the first x (default 30) characters of self.body for the Element#preview_text method.
  def preview_text(maxlength = 30)
    body.to_s[0..maxlength]
  end
  
  # Returns self.body. Used for Content#ingredient method.
  def ingredient
    self.body
  end
  
  # Saves the content from params
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.body = params["body"]
    self.link = params["link"]
    self.title = params["title"]
    self.link_class_name = params["link_class_name"]
    self.open_link_in_new_window = (params["open_link_in_new_window"] == '1')
    self.public = options[:public]
    self.save!
  end
  
private
  
  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end
  
end
