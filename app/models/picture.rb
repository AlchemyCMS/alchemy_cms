class Picture < ActiveRecord::Base
  
  acts_as_fleximage do
    image_directory           'uploads/pictures'
    image_storage_format      Alchemy::Configuration.parameter(:image_store_format).to_sym
    require_image             true
    missing_image_message     N_("missing_image")
    invalid_image_message     N_("not a valid image")
    if Alchemy::Configuration.parameter(:image_output_format) == "jpg"
      output_image_jpg_quality  Alchemy::Configuration.parameter(:output_image_jpg_quality)
    end
    unless Alchemy::Configuration.parameter(:preprocess_image_resize).blank?
      preprocess_image do |image|
        image.resize Alchemy::Configuration.parameter(:preprocess_image_resize)
      end
    end
  end
  
  stampable
  
  # Returning the filepath relative to Rails.root public folder.
  def public_file_path
    self.file_path.gsub("#{Rails.root}/public", '')
  end
  
  def urlname
    if self.name.blank?
     "image_#{self.id}"
   else
     CGI.escape(self.name.gsub(/\.(gif|png|jpe?g|tiff?)/i, '').gsub(/\./, ' '))
   end
  end
  
  # Returning true if picture's width is greater than it's height
  def landscape_format?
    return (self.image_width > self.image_height) ? true : false
  end
  
  # Returning true if picture's width is smaller than it's height
  def portrait_format?
    return (self.image_width < self.image_height) ? true : false
  end
  
  # Returning true if picture's width and height is equal
  def square_format?
    return (self.image_width == self.image_height) ? true : false
  end
  
end
