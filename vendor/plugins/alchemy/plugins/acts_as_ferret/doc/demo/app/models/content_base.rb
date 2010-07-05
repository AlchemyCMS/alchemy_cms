# common base class for Content and SpecialContent
class ContentBase < ActiveRecord::Base
  set_table_name 'contents'

  # a higher boost means more importance for the field --> documents having a
  # match in a field with a higher boost value will be ranked higher
  #
  # we use the store_class_name flag to be able to retrieve model instances when
  # searching multiple indexes at once.
  # the contents of the description field are stored in the index for running
  # 'more like this' queries to find other content instances with similar
  # descriptions
  acts_as_ferret( :fields => { :comment_count => { :index => :untokenized },
                               :title         => { :boost => :title_boost }, 
                               :description   => { :boost => 1, :store => :yes },
                               :special       => {} },
                  :boost => :record_boost)

  def comment_count; 0 end

  attr_accessor :record_boost
  attr_writer :title_boost
  def title_boost
    @title_boost || 2
  end
end


