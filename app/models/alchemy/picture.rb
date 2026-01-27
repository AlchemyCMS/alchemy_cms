# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_pictures
#
#  id                :integer          not null, primary key
#  name              :string
#  image_file_name   :string
#  image_file_width  :integer
#  image_file_height :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#  upload_hash       :string
#  cached_tag_list   :text
#  image_file_uid    :string
#  image_file_size   :integer
#  image_file_format :string
#

module Alchemy
  class Picture < BaseRecord
    THUMBNAIL_SIZES = {
      small: "80x60",
      medium: "160x120",
      large: "240x180"
    }.with_indifferent_access.freeze

    include Alchemy::NameConversions
    include Alchemy::Taggable
    include Alchemy::TouchElements
    include Alchemy::RelatableResource

    has_many :descriptions, class_name: "Alchemy::PictureDescription", dependent: :destroy

    accepts_nested_attributes_for :descriptions, allow_destroy: true, reject_if: ->(attr) { attr[:text].blank? }

    # Raise error, if picture is in use (aka. assigned to an Picture ingredient)
    #
    # === CAUTION
    #
    # This HAS to be placed for Dragonfly's class methods,
    # to ensure this runs before Dragonfly's before_destroy callback.
    #
    before_destroy unless: :deletable? do
      raise PictureInUseError, Alchemy.t(:cannot_delete_picture_notice) % {name: name}
    end

    # Image preprocessing class
    def self.preprocessor_class
      @_preprocessor_class ||= Alchemy.storage_adapter.preprocessor_class
    end

    # Set a image preprocessing class
    #
    #     # config/initializers/alchemy.rb
    #     Alchemy::Picture.preprocessor_class = My::ImagePreprocessor
    #
    def self.preprocessor_class=(klass)
      @_preprocessor_class = klass
    end

    before_create :set_name, if: :image_file_name

    include Alchemy.storage_adapter.picture_class_methods

    # We need to define this method here to have it available in the validations below.
    class << self
      def allowed_filetypes
        Alchemy.config.uploader.allowed_filetypes.alchemy_pictures
      end
    end

    validates_presence_of :image_file
    validates_size_of :image_file, maximum: Alchemy.config.uploader.file_size_limit.megabytes
    validate :image_file_type_allowed, if: -> { image_file.present? }

    stampable stamper_class_name: Alchemy.config.user_class_name

    scope :named, ->(name) { where("#{table_name}.name LIKE ?", "%#{name}%") }
    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: {id: nil}) }
    scope :by_file_format, ->(file_format) do
      Alchemy.storage_adapter.by_file_format_scope(file_format)
    end

    # Case insensitive Ransack searching and sorting for name attribute
    ransacker :name, type: :string do
      arel_table[:name].lower
    end

    # Class methods

    class << self
      # The class used to generate URLs for pictures
      #
      def url_class
        @_url_class ||= Alchemy.storage_adapter.picture_url_class
      end

      # Set a different picture url class
      #
      # @see Alchemy::Picture::Url
      def url_class=(klass)
        @_url_class = klass
      end

      def searchable_alchemy_resource_attributes
        Alchemy.storage_adapter.searchable_alchemy_resource_attributes(name)
      end

      def ransackable_attributes(_auth_object = nil)
        Alchemy.storage_adapter.ransackable_attributes(name)
      end

      def ransackable_associations(_auth_object = nil)
        Alchemy.storage_adapter.ransackable_associations(name)
      end

      def last_upload
        last_picture = Picture.last
        return Picture.all unless last_picture

        Picture.where(upload_hash: last_picture.upload_hash)
      end

      def ransackable_scopes(_auth_object = nil)
        [:by_file_format, :recent, :last_upload, :without_tag, :deletable]
      end

      def file_formats(scope = all, from_extensions: nil)
        Alchemy.storage_adapter.file_formats(name, scope:, from_extensions:)
      end
    end

    # Instance methods

    # Returns an url (or relative path) to a processed image for use inside an image_tag helper.
    #
    # Example:
    #
    #   <%= image_tag picture.url(size: '320x200', format: 'png') %>
    #
    # @return [String|Nil]
    def url(options = {})
      return unless image_file

      self.class.url_class.new(self).call(options)
    rescue Alchemy.storage_adapter.rescuable_errors => e
      Logger.warn(e.message)
      nil
    end

    # Returns an url for the thumbnail representation of the picture
    #
    # @param [String] size - The size of the thumbnail
    #
    # @return [String]
    def thumbnail_url(size: "160x120")
      return if image_file.nil?

      url(
        flatten: true,
        format: image_file_extension || "jpg",
        size: size
      )
    end

    # Updates name and tag_list attributes.
    #
    # Used by +Admin::PicturesController#update_multiple+
    #
    # Note: Does not delete name value, if the form field is blank.
    #
    def update_name_and_tag_list!(params)
      if params[:pictures_name].present?
        self.name = params[:pictures_name]
      end
      self.tag_list = params[:pictures_tag_list]
      save!
    end

    # Returns the picture description for a given language.
    def description_for(language)
      descriptions.find_by(language: language)&.text
    end

    # Returns an uri escaped name.
    #
    def urlname
      if name.blank?
        "image_#{id}"
      else
        ::CGI.escape(name.gsub(/\.(gif|png|jpe?g|tiff?)/i, "").tr(".", " "))
      end
    end

    # Returns the format the image should be rendered with
    #
    # Only returns a format differing from original if an +image_output_format+
    # is set in config and the image has a convertible file format.
    #
    def default_render_format
      if convertible?
        Alchemy.config.image_output_format
      else
        image_file_extension
      end
    end

    # Returns true if the image can be converted
    #
    # If the +image_output_format+ is set to +nil+ or +original+ or the
    # image has not a convertible file format (i.e. SVG) this returns +false+
    #
    def convertible?
      Alchemy.config.image_output_format &&
        Alchemy.config.image_output_format != "original" &&
        has_convertible_format?
    end

    # Returns true if the image can be converted into other formats
    #
    def has_convertible_format?
      Alchemy.storage_adapter.has_convertible_format?(self)
    end

    # Checks if the picture is restricted.
    #
    # A picture is only restricted if it's assigned on restricted pages only.
    #
    # Once a picture is assigned on a not restricted page,
    # it is considered public and therefore not restricted any more,
    # even if it is also assigned on a restricted page.
    #
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    def image_file_name
      Alchemy.storage_adapter.image_file_name(self)
    end

    def image_file_format
      Alchemy.storage_adapter.image_file_format(self)
    end

    def image_file_size
      Alchemy.storage_adapter.image_file_size(self)
    end

    def image_file_width
      Alchemy.storage_adapter.image_file_width(self)
    end

    def image_file_height
      Alchemy.storage_adapter.image_file_height(self)
    end

    def image_file_extension
      Alchemy.storage_adapter.image_file_extension(self)
    end
    alias_method :suffix, :image_file_extension
    deprecate suffix: :image_file_extension, deprecator: Alchemy::Deprecation

    def svg?
      image_file_format == "image/svg+xml"
    end

    # A size String from original image file values.
    #
    # == Example
    #
    # 200 x 100
    #
    def image_file_dimensions
      "#{image_file_width}x#{image_file_height}"
    end

    private

    # Returns a humanized, readable name from image filename.
    #
    def set_name
      self.name ||= Alchemy.storage_adapter.image_file_basename(self).humanize
    end

    def image_file_type_allowed
      unless image_file_extension&.in?(self.class.allowed_filetypes)
        errors.add(:image_file, Alchemy.t("not a valid image"))
      end
    end
  end
end
