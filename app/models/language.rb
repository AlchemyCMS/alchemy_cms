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
  
  def self.all_for_created_language_trees
    created_languages = Page.language_roots.collect(&:language)
    Language.all_for_collection(created_languages)
  end
  
  def self.find_code_for(code)
    l = Language.find_by_code(code, :select => :code)
    return nil if l.blank?
    l.code
  end
  
  def self.all_codes_for_published
    Language.all(:select => :code, :conditions => {:public => true}).collect(&:code)
  end
  
end
