class EssenceHtml < ActiveRecord::Base
  stampable
  
  # Returns the first x (default = 30) (HTML escaped) characters from self.source for the Element#preview_text method.
  def preview_text(maxlength = 30)
    CGI.escapeHTML(source.to_s)[0..maxlength]
  end
  
  # Returns self.source. Used for Content#ingredient method.
  def ingredient
    self.source
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.source = params["source"].to_s
    self.save!
  end
  
end