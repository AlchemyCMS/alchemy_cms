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

    dragonfly_accessor :file, app: :alchemy_attachments do
      after_assign { |f| write_attribute(:file_mime_type, f.mime_type) }
    end

    stampable stamper_class_name: Alchemy.user_class.name

    has_many :file_ingredients,
      class_name: "Alchemy::Ingredients::File",
      foreign_key: "related_object_id",
      inverse_of: :related_object

    has_many :elements, through: :file_ingredients
    has_many :pages, through: :elements

    scope :by_file_type, ->(file_type) { where(file_mime_type: file_type) }
    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: { id: nil }) }

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
            values: distinct.pluck(:file_mime_type).map { |type| [Alchemy.t(type, scope: "mime_types"), type] }.sort_by(&:first),
          },
          {
            name: :misc,
            values: %w(recent last_upload without_tag),
          },
        ]
      end

      def last_upload
        last_id = Attachment.maximum(:id)
        return Attachment.all unless last_id

        where(id: last_id)
      end

      def searchable_alchemy_resource_attributes
        %w(name file_name)
      end

      def allowed_filetypes
        Config.get(:uploader).fetch("allowed_filetypes", {}).fetch("alchemy/attachments", [])
      end
    end

    validates_presence_of :file
    validates_size_of :file, maximum: Config.get(:uploader)["file_size_limit"].megabytes
    validates_property :ext,
      of: :file,
      in: allowed_filetypes,
      case_sensitive: false,
      message: Alchemy.t("not a valid file"),
      unless: -> { self.class.allowed_filetypes.include?("*") }

    before_save :set_name, if: :file_name_changed?

    scope :with_file_type, ->(file_type) { where(file_mime_type: file_type) }

    # Instance methods

    def to_jq_upload
      {
        "name" => read_attribute(:file_name),
        "size" => read_attribute(:file_size),
        "error" => errors[:file].join,
      }
    end

    def url(options = {})
      if file
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

    # File format suffix
    def extension
      file_name.split(".").last
    end

    alias_method :suffix, :extension

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case file_mime_type
      when "application/pdf"
        "file-pdf"
      when "application/msword"
        "file-word"
      when *TEXT_FILE_TYPES
        "file-alt"
      when *EXCEL_FILE_TYPES
        "file-excel"
      when *POWERPOINT_FILE_TYPES
        "file-powerpoint"
      when *WORD_FILE_TYPES
        "file-word"
      when *VCARD_FILE_TYPES
        "address-card"
      when *ARCHIVE_FILE_TYPES
        "file-archive"
      when *AUDIO_FILE_TYPES
        "file-audio"
      when *IMAGE_FILE_TYPES
        "file-image"
      when *VIDEO_FILE_TYPES
        "file-video"
      else
        "file"
      end
    end

    private

    def set_name
      self.name = convert_to_humanized_name(file_name, file.ext)
    end
  end
end
