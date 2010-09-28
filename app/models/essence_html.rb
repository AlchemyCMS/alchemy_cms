class EssenceHtml < ActiveRecord::Base
  stampable
  
  # Returns the first 30 (HTML escaped) characters from self.source for the Element#preview_text method.
  def preview_text
    CGI.escapeHTML(source.to_s)[0..30]
  end
  
  # Returns self.source. Used for Content#ingredient method.
  def ingredient
    self.source
  end
  
end