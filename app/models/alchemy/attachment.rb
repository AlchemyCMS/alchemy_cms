# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_attachments
#
#  id              :integer          not null, primary key
#  name            :string
#  file_name       :string
#  file_mime_type  :string
#  file_size       :integer
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cached_tag_list :text
#  file_uid        :string
#

module Alchemy
  class Attachment < BaseRecord
    include Alchemy::Filetypes
    include Alchemy::NameConversions
    include Alchemy::Taggable
    include Alchemy::TouchElements

    has_one_attached(:file)

    stampable stamper_class_name: Alchemy.user_class.name

    has_many :file_ingredients,
      class_name: "Alchemy::Ingredients::File",
      foreign_key: "related_object_id",
      inverse_of: :related_object

    has_many :elements, through: :file_ingredients
    has_many :pages, through: :elements

    scope :by_file_type,
      ->(file_type) {
        with_attached_file.joins(:file_blob).where(active_storage_blobs: {content_type: file_type})
      }

    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: {id: nil}) }

    # We need to define this method here to have it available in the validations below.
    class << self
      # The class used to generate URLs for attachments
      #
      # @see Alchemy::Attachment::Url
      def url_class
        @_url_class ||= Alchemy::Attachment::Url
      end

      # Set a different attachment url class
      #
      # @see Alchemy::Attachment::Url
      def url_class=(klass)
        @_url_class = klass
      end

      def alchemy_resource_filters
        [
          {
            name: :by_file_type,
            values: file_types
          },
          {
            name: :misc,
            values: %w[recent last_upload without_tag]
          }
        ]
      end

      def last_upload
        last_id = Attachment.maximum(:id)
        return Attachment.all unless last_id

        where(id: last_id)
      end

      def searchable_alchemy_resource_attributes
        %w[name file_name]
      end

      def allowed_filetypes
        Config.get(:uploader).fetch("allowed_filetypes", {}).fetch("alchemy/attachments", [])
      end

      private

      def file_types
        ActiveStorage::Blob.joins(:attachments).merge(
          ActiveStorage::Attachment.where(record_type: name)
        ).distinct.pluck(:content_type)
      end
    end

    validates_presence_of :file

    validate :file_not_too_big, if: -> { file.present? }

    validate :file_type_allowed,
      unless: -> { self.class.allowed_filetypes.include?("*") },
      if: -> { file.present? }

    before_save :set_name, if: :file_name_changed?

    scope :with_file_type, ->(file_type) { where(file_mime_type: file_type) }

    # Instance methods

    def to_jq_upload
      {
        "name" => read_attribute(:file_name),
        "size" => read_attribute(:file_size),
        "error" => errors[:file].join
      }
    end

    def url(options = {})
      if file.present?
        self.class.url_class.new(self).call(options)
      end
    end

    # An url save filename without format suffix
    def slug
      CGI.escape(file_name.gsub(/\.#{extension}$/, "").tr(".", " "))
    end

    # Checks if the attachment is restricted, because it is attached on restricted pages only
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    # File name
    def file_name
      file&.filename&.to_s
    end

    # File size
    def file_size
      file&.byte_size
    end

    def file_mime_type
      file&.content_type
    end

    # File format suffix
    def extension
      file&.filename&.extension
    end

    alias_method :suffix, :extension

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case file_mime_type
      when "application/pdf"
        "file-pdf-2"
      when *TEXT_FILE_TYPES
        "file-text"
      when *EXCEL_FILE_TYPES
        "file-excel-2"
      when *POWERPOINT_FILE_TYPES
        "file-ppt-2"
      when *WORD_FILE_TYPES
        "file-word-2"
      when *VCARD_FILE_TYPES
        "profile"
      when *ARCHIVE_FILE_TYPES
        "file-zip"
      when *AUDIO_FILE_TYPES
        "file-music"
      when *IMAGE_FILE_TYPES
        "file-image"
      when *VIDEO_FILE_TYPES
        "file-video"
      else
        "file-3"
      end
    end

    private

    def file_type_allowed
      unless extension&.in?(self.class.allowed_filetypes)
        errors.add(:image_file, Alchemy.t("not a valid file"))
      end
    end

    def file_not_too_big
      maximum = Config.get(:uploader)["file_size_limit"]&.megabytes
      return true unless maximum

      if file_size > maximum
        errors.add(:file, :too_big)
      end
    end

    def set_name
      self.name = convert_to_humanized_name(file_name, extension)
    end
  end
end
