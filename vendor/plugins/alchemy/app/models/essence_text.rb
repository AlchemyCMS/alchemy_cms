class EssenceText < ActiveRecord::Base
  
  acts_as_ferret(:fields => {:content => {:store => :yes}}, :remote => false) if WaConfigure.parameter(:ferret) == true
  stampable
  before_save :check_ferret_indexing if WaConfigure.parameter(:ferret) == true
  
  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end
  
end
