class EssenceFile < ActiveRecord::Base
  belongs_to :attachment
  stampable
  
  # Returns self.attachment.name for the Element#preview_text method.
  def preview_text
    return "" if attachment.blank?
    attachment.name.to_s
  end
  
end