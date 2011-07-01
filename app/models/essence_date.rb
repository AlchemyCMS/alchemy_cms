class EssenceDate < ActiveRecord::Base
  
  acts_as_essence(
    :ingredient_column => :date
  )
  
  # Returns self.date for the Element#preview_text method.
  def preview_text(foo=nil)
    return "" if date.blank?
    I18n.l(date)
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.date = DateTime.parse(params['date'].values.join('-'))
    self.save
  end
  
end
