class EssenceDate < ActiveRecord::Base
  
  stampable
  
  @@date_parts = ["%Y", "%m", "%d", "%H", "%M"]
  
  # Returns self.date for the Element#preview_text method.
  def preview_text
    return "" if date.blank?
    I18n.l(date)
  end
  
  # Returns self.date. Used for Content#ingredient method.
  def ingredient
    self.date
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    raise Alchemy::EssenceError.new("params are blank for EssenceDate#id = #{self.id}") if params.blank?
    self.date = DateTime.strptime(params.values.join('-'), @@date_parts[0, params.length].join("-"))
    self.save!
  end
  
end
