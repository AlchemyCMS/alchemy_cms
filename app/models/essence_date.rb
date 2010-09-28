class EssenceDate < ActiveRecord::Base
  stampable
  
  # Returns self.date for the Element#preview_text method.
  def preview_text
    return "" if date.blank?
    I18n.l(date)
  end
  
  # Returns self.date. Used for Content#ingredient method.
  def ingredient
    self.date
  end
  
end