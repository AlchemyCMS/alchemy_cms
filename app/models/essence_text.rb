class EssenceText < ActiveRecord::Base
  
  acts_as_ferret(:fields => {:body => {:store => :yes}}, :remote => false) if Alchemy::Configuration.parameter(:ferret) == true
  stampable
  before_save :check_ferret_indexing if Alchemy::Configuration.parameter(:ferret) == true
  
  # Returns the first 30 characters of self.body for the Element#preview_text method.
  def preview_text
    body.to_s[0..30]
  end
  
  # Returns self.body. Used for Content#ingredient method.
  def ingredient
    self.body
  end
  
  # Saves the content from params
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.body = params["body"].to_s
    self.link = params["link"].to_s
    self.title = params["title"].to_s
    self.link_class_name = params["link_class_name"].to_s
    self.open_link_in_new_window = params["open_link_in_new_window"] == 1 ? true : false
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
