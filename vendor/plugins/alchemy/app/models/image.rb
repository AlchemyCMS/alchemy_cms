class Image < ActiveRecord::Base
  
  acts_as_fleximage do
    image_directory           'public/uploads/images'
    image_storage_format      Configuration.parameter(:image_store_format).to_sym
    require_image             true
    missing_image_message     N_("missing_image")
    invalid_image_message     N_("not a valid image")
    if Configuration.parameter(:image_output_format) == "jpg"
      output_image_jpg_quality  Configuration.parameter(:output_image_jpg_quality)
    end
    unless Configuration.parameter(:preprocess_image_resize).blank?
      preprocess_image do |image|
        image.resize Configuration.parameter(:preprocess_image_resize)
      end
    end
  end
  
  stampable
  
  # Returning the filepath relative to Rails.root public folder.
  def public_file_path
    self.file_path.gsub("#{Rails.root}/public", '')
  end
  
  def urlname
    self.name.blank? ? "image_#{self.id}" : self.name.split(/\./).first
  end
  
end
