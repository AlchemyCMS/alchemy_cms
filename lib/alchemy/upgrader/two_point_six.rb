module Alchemy
  module Upgrader::TwoPointSix

  private

    def convert_attachment_storage
      desc "Convert the attachment storage"
      converted_files = []
      files = Dir.glob Rails.root.join 'uploads/attachments/**/*.*'
      if files.blank?
        log "No attachments found", :skip
      else
        files.each do |file|
          file_uid = file.gsub(/#{Rails.root.to_s}\/uploads\/attachments\//, '')
          file_id = file_uid.split('/')[1].to_i
          attachment = Alchemy::Attachment.find_by_id(file_id)
          if attachment && attachment.file_uid.blank?
            attachment.file_uid = file_uid
            attachment.file_size = File.new(file).size
            attachment.file_name = attachment.sanitized_filename
            if attachment.save!
              log "Converted #{file_uid}"
            end
          else
            log "Attachment with id #{file_id} not found or already converted.", :skip
          end
        end
      end
    end

  end
end
