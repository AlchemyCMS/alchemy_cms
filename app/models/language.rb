class Language < ActiveRecord::Base
  
  validates_presence_of :name
  validates_presence_of :code
  validates_presence_of :page_layout
  validates_presence_of :frontpage_name
  validates_uniqueness_of :code
  
  named_scope :published, :conditions => {:public => true}
   
  def self.all_for_collection(created)
    Language.all( :conditions => "code IN ('#{created.join('\',\'')}')" )
  end
  
end
