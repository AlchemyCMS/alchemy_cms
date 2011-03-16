class EssenceFlash < ActiveRecord::Base
  
  acts_as_essence(
    :ingredient_column => :attachment,
    :preview_text_method => :name
  )
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.attachment_id = params["attachment_id"].to_s
    self.save
  end
  
end
