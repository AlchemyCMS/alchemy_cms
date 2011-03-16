class EssenceDate < ActiveRecord::Base
  
  acts_as_essence(
    :ingredient_column => :date
  )
  
  @@date_parts = ["%Y", "%m", "%d", "%H", "%M"]
  
  # Returns self.date for the Element#preview_text method.
  def preview_text(foo=nil)
    return "" if date.blank?
    I18n.l(date)
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.date = DateTime.strptime(params.values.join('-'), @@date_parts[0, params.length].join("-"))
    self.save
  end
  
end
