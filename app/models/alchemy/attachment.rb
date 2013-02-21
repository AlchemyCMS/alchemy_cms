require 'alchemy/filetypes'

module Alchemy
  class Attachment < ActiveRecord::Base
    include Filetypes

    has_many :essence_files, :class_name => 'Alchemy::EssenceFile', :foreign_key => 'attachment_id'
    has_many :contents, :through => :essence_files
    has_many :elements, :through => :contents
    has_many :pages, :through => :elements

    attr_accessible :uploaded_data, :name, :filename, :tag_list

    stampable(:stamper_class_name => 'Alchemy::User')

    acts_as_taggable
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
      parts = filename.split('.')
      sfx = parts.pop
      "#{parts.join('-')}.#{sfx}"
    end

    # Checks if the attachment is restricted, because it is attached on restricted pages only
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    def extension
      filename.split(".").last
    end
    alias_method :suffix, :extension

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case content_type
        when *ARCHIVE_FILE_TYPES
          then "archive"
        when *AUDIO_FILE_TYPES
          then "audio"
        when *IMAGE_FILE_TYPES
          then "image"
        when *VIDEO_FILE_TYPES
          then "video"
        when "application/x-shockwave-flash"
          then "flash"
        when "image/x-psd"
          then "psd"
        when "text/plain"
          then "text"
        when "application/rtf"
          then "rtf"
        when "application/pdf"
          then "pdf"
        when "application/msword"
          then "word"
        when "application/vnd.ms-excel"
          then "excel"
        when *VCARD_FILE_TYPES
          then "vcard"
        else "file"
      end
    end

  end
end
