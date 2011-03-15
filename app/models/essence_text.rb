class EssenceText < ActiveRecord::Base
  
  acts_as_essence
  acts_as_ferret(:fields => {:body => {:store => :yes}}, :remote => false) if Alchemy::Configuration.parameter(:ferret) == true
  
  before_save :check_ferret_indexing if Alchemy::Configuration.parameter(:ferret) == true
  
  # Saves the content from params
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.body = params["body"]
    self.link = params["link"]
    self.title = params["title"]
    self.link_class_name = params["link_class_name"]
    self.open_link_in_new_window = (params["open_link_in_new_window"] == '1')
    self.public = options[:public]
    self.save
  end
  
private
  
  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end
  
end
