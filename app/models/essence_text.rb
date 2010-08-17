class EssenceText < ActiveRecord::Base
  
  acts_as_ferret(:fields => {:body => {:store => :yes}}, :remote => false) if Alchemy::Configuration.parameter(:ferret) == true
  stampable
  before_save :check_ferret_indexing if Alchemy::Configuration.parameter(:ferret) == true
  
  # Returns the first 30 characters of self.body for the Element#preview_text method.
  def preview_text
    body.to_s[0..30]
  end
  
  private
  
  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end
  
end
