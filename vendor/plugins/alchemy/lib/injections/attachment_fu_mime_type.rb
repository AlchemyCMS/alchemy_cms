Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  # Overriding this method to allow content_type to be detected when
  # swfupload submits images with content_type set to 'application/octet-stream'
  def uploaded_data=(file_data)
    return nil if file_data.nil? || file_data.size == 0
    self.content_type = detect_mimetype(file_data)
    self.filename     = file_data.original_filename if respond_to?(:filename)
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path = file_data.path
    end
  end
  
  def detect_mimetype(file_data)
    if file_data.content_type.strip == "application/octet-stream"
      return File.mime_type?(file_data.original_filename)
    else
      return file_data.content_type
    end
  end
end