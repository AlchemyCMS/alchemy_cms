class EssenceAudio < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
  # Returns self.attachment.name for the Element#preview_text method.
  def preview_text
    return "" if attachment.blank?
    attachment.name.to_s
  end
  
  # Returns self.attachment. Used for Content#ingredient method.
  def ingredient
    self.attachment
  end
  
  # Saves the ingredient
  def save_ingredient(params, options = {})
    raise Alchemy::EssenceError.new("params are blank for EssenceAudio#id = #{self.id}") if params.blank?
    self.attachment_id = params["attachment_id"].to_s
    self.save!
  end
  
end
