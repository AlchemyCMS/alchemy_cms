
class PlainAsciiAnalyzer < ::Ferret::Analysis::Analyzer
  include ::Ferret::Analysis
  def token_stream(field, str)
        StopFilter.new(
          StandardTokenizer.new(str) ,
          ["fax", "gsm"]
        )
    # raise #<<<----- is never executed when uncommented !!
  end
end


class Comment < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Content', :foreign_key => :parent_id
  
  # simplest case: just index all fields of this model:
  # acts_as_ferret
  
  # use the :additional_fields property to specify fields you intend 
  # to add in addition to those fields from your database table (which will be
  # autodiscovered by acts_as_ferret)
  # the :ignore flag tells aaf to not try to set this field's value itself (we
  # do this in our custom to_doc method)
  acts_as_ferret( :if => Proc.new { |comment| comment.do_index? },
                  :fields => {
                    :content => { :store => :yes },
                    :author  => { },
                    :added   => { :index => :untokenized, :store => :yes, :ignore => true },
                    :aliased => { :via => :content }
                  }, :ferret => { :analyzer => Ferret::Analysis::StandardAnalyzer.new(['fax', 'gsm', 'the', 'or']) } )
                  #}, :ferret => { :analyzer => PlainAsciiAnalyzer.new(['fax', 'gsm', 'the', 'or']) } )

  def do_index?
    self.content !~ /do not index/
  end

  # you can override the default to_doc method 
  # to customize what gets into your index. 
  def to_doc
    # doc now has all the fields of our model instance, we 
    # just add another field to it:
    doc = super
    # add a field containing the current time
    doc[:added] = Time.now.to_i.to_s
    return doc
  end
end
