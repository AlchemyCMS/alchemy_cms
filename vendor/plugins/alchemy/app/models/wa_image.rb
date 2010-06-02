class WaImage < ActiveRecord::Base
  
  acts_as_fleximage do
    image_directory           'public/uploads/images'
    image_storage_format      WaConfigure.parameter(:image_store_format).to_sym
    require_image             true
    missing_image_message     N_("missing_image")
    invalid_image_message     N_("not a valid image")
    if WaConfigure.parameter(:image_output_format) == "jpg"
      output_image_jpg_quality  WaConfigure.parameter(:output_image_jpg_quality)
    end
    unless WaConfigure.parameter(:preprocess_image_resize).blank?
      preprocess_image do |image|
        image.resize WaConfigure.parameter(:preprocess_image_resize)
      end
    end
  end
  
  stampable :stamper_class_name => :wa_user
  
  # Returning the filepath relative to Rails.root public folder.
  def public_file_path
    self.file_path.gsub("#{Rails.root}/public", '')
  end
  
  def urlname
    self.name.blank? ? "image_#{self.id}" : self.name.split(/\./).first
  end
  
end
