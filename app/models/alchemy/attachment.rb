module Alchemy
  class Attachment < ActiveRecord::Base

    attr_accessible :uploaded_data, :name

    stampable(:stamper_class_name => 'Alchemy::User')

    has_attachment(
      :storage => :file_system,
      :file_system_path => 'uploads/attachments',
      :size => 0.kilobytes..1000.megabytes
    )
    validates_as_attachment

    def self.find_paginated(params, per_page)
      attachments = Attachment.arel_table
      cond = attachments[:name].matches("%#{params[:query]}%").or(attachments[:filename].matches("%#{params[:query]}%"))
      self.where(cond).page(params[:page] || 1).per(per_page).order(:name)
    end

    def urlname
      ::CGI.escape(read_attribute(:filename).split('.').first)
    end

    def extension
      filename.split(".").last
    end

    alias_method :suffix, :extension

    def icon_css_class
      case content_type
      when "application/x-flash-video" then "video"
      when "video/x-flv" then "video"
      when "video/mp4" then "video"
      when "video/mpeg" then "video"
      when "video/quicktime" then "video"
      when "video/x-msvideo" then "video"
      when "video/x-ms-wmv" then "video"
      when "application/zip" then "archive"
      when "application/x-rar" then "archive"
      when "audio/mpeg" then "audio"
      when "audio/mp4" then "audio"
      when "audio/wav" then "audio"
      when "audio/x-wav" then "audio"
      when "application/x-shockwave-flash" then "flash"
      when "image/gif" then "image"
      when "image/jpeg" then "image"
      when "image/png" then "image"
      when "image/tiff" then "image"
      when "image/x-psd" then "psd"
      when "text/plain" then "text"
      when "application/rtf" then "rtf"
      when "application/pdf" then "pdf"
      when "application/msword" then "word"
      when "application/vnd.ms-excel" then "excel"
      when "text/x-vcard" then "vcard"
      when "application/vcard" then "vcard"
      else "file"
      end
    end

  end
end
