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
  
  # Returns the default centered image mask for a given size
  def default_mask(size)
    raise "No size given" if size.blank?
    width = size.split('x')[0].to_i
    height = size.split('x')[1].to_i
    if (width > height)
      zoom_factor = image_width.to_f / width
      mask_height = (height * zoom_factor).round
      x1 = 0
      x2 = image_width
      y1 = (image_height - mask_height) / 2
      y2 = y1 + mask_height
    elsif (width == 0 && height == 0)
      x1 = 0
      x2 = image_width
      y1 = 0
      y2 = image_height
    else
      zoom_factor = image_height.to_f / height
      mask_width = (width * zoom_factor).round
      x1 = (image_width - mask_width) / 2
      x2 = x1 + mask_width
      y1 = 0
      y2 = image_height
    end
    {
      :x1 => x1,
      :y1 => y1,
      :x2 => x2,
      :y2 => y2
    }
  end
  
  def cropped_thumbnail_size(size)
    return size if size == "111x93" || size.blank?
    x = size.split('x')[0].to_i
    y = size.split('x')[1].to_i
    if (x > y)
      zoom_factor = 111.0 / x
      new_x = 111
      new_y = y * zoom_factor
    else
      zoom_factor = 93.0 / y
      new_x = x * zoom_factor
      new_y = 93
    end
    "#{new_x.round}x#{new_y.round}"
  end
  
end
