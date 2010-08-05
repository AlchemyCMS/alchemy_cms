class EssenceRichtext < ActiveRecord::Base
  
  acts_as_ferret(:fields => {:stripped_body => {:store => :yes}}, :remote => false) if Alchemy::Configuration.parameter(:ferret) == true
  stampable
  before_save :strip_content
  before_save :check_ferret_indexing if Alchemy::Configuration.parameter(:ferret) == true
  
  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end
  
  def strip_content
    self.stripped_body = strip_tags(self.body)
  end
  
  def strip_tags(html)
    return html if html.blank?
    if html.index("<")
      text = ""
      tokenizer = HTML::Tokenizer.new(html)
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        # result is only the content of any Text nodes
        text << node.to_s if node.class == HTML::Text
      end
      # strip any comments, and if they have a newline at the end (ie. line with
      # only a comment) strip that too
      text.gsub(/<!--(.*?)-->[\n]?/m, "")
    else
      html # already plain text
    end
  end
  
end
