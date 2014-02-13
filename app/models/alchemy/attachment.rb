# == Schema Information
#
# Table name: alchemy_attachments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  file_name       :string(255)
#  file_mime_type  :string(255)
#  file_size       :integer
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cached_tag_list :text
#  file_uid        :string(255)
#

module Alchemy
  class Attachment < ActiveRecord::Base
    include Alchemy::Filetypes
    include Alchemy::NameConversions
    include Alchemy::Touching

    acts_as_taggable

    dragonfly_accessor :file, app: :alchemy_attachments do
      after_assign { |f| write_attribute(:file_mime_type, f.mime_type) }
    end

    stampable stamper_class_name: Alchemy.user_class_name

    has_many :essence_files, :class_name => 'Alchemy::EssenceFile', :foreign_key => 'attachment_id'
    has_many :contents, :through => :essence_files
    has_many :elements, :through => :contents
    has_many :pages, :through => :elements

    validates_presence_of :file
    validates_format_of :file_name, with: /\A[A-Za-z0-9\.\-_]+\z/, on: :update
    validates_size_of :file, maximum: Config.get(:uploader)['file_size_limit'].megabytes
    validates_property :ext, of: :file,
      in: Config.get(:uploader)['allowed_filetypes']['attachments'],
      case_sensitive: false,
      message: I18n.t("not a valid file"),
      unless: -> { Config.get(:uploader)['allowed_filetypes']['attachments'].include?('*') }

    before_create do
      write_attribute(:name, convert_to_humanized_name(self.file_name, self.file.ext))
      write_attribute(:file_name, sanitized_filename)
    end

    after_update :touch_contents

    # Class methods

    class << self

      def find_paginated(params, per_page, order)
        attachments = Attachment.arel_table
        cond = attachments[:name].matches("%#{params[:query]}%").or(attachments[:file_name].matches("%#{params[:query]}%"))
        self.where(cond).page(params[:page] || 1).per(per_page).order(order)
      end

    end

    # Instance methods

    def to_jq_upload
      {
        "name" => read_attribute(:file_name),
        "size" => read_attribute(:file_size),
        'error' => errors[:file].join
      }
    end

    def urlname
      read_attribute :file_name
    end

    # Checks if the attachment is restricted, because it is attached on restricted pages only
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    def extension
      file_name.split(".").last
    end
    alias_method :suffix, :extension

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case file_mime_type
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

    def sanitized_filename
      parts = self.file_name.split('.')
      sfx = parts.pop
      name = convert_to_urlname(parts.join('-'))
      "#{name}.#{sfx}"
    end

  end
end
