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

    TRANSFORMATION_OPTIONS = [
      :crop,
      :crop_from,
      :crop_size,
      :flatten,
      :format,
      :quality,
      :size,
      :upsample
    ]

    include Alchemy::Logger
    include Alchemy::NameConversions
    include Alchemy::Taggable
    include Alchemy::TouchElements

    has_many :picture_ingredients,
      class_name: "Alchemy::Ingredients::Picture",
      foreign_key: "related_object_id",
      inverse_of: :related_object

    has_many :elements, through: :picture_ingredients
    has_many :pages, through: :elements

    # Raise error, if picture is in use (aka. assigned to an Picture ingredient)
    #
    # === CAUTION
    #
    # This HAS to be placed for ActiveStorage class methods,
    # to ensure this runs before ActiveStorage before_destroy callback.
    #
    before_destroy unless: :deletable? do
      raise PictureInUseError, Alchemy.t(:cannot_delete_picture_notice) % {name: name}
    end

    # Image preprocessing class
    def self.preprocessor_class
      @_preprocessor_class ||= Preprocessor
    end

    # Set a image preprocessing class
    #
    #     # config/initializers/alchemy.rb
    #     Alchemy::Picture.preprocessor_class = My::ImagePreprocessor
    #
    def self.preprocessor_class=(klass)
      @_preprocessor_class = klass
    end

    # Use ActiveStorage image processing
    has_one_attached(:image_file)

    validates_presence_of :image_file
    validate :image_file_type_allowed, :image_file_not_too_big,
      if: -> { image_file.present? }

    stampable stamper_class_name: Alchemy.user_class.name

    scope :named, ->(name) { where("#{table_name}.name LIKE ?", "%#{name}%") }
    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :deletable,
      -> {
        where("#{table_name}.id NOT IN (SELECT related_object_id FROM alchemy_ingredients WHERE related_object_type = 'Alchemy::Picture')")
      }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: {id: nil}) }
    scope :by_file_format,
      ->(file_format) {
        with_attached_image_file.joins(:image_file_blob).where(active_storage_blobs: {content_type: file_format})
      }

    # Class methods

    class << self
      # The class used to generate URLs for pictures
      #
      # @see Alchemy::Picture::Url
      def url_class
        @_url_class ||= Alchemy::Picture::Url
      end

      # Set a different picture url class
      #
      # @see Alchemy::Picture::Url
      def url_class=(klass)
        @_url_class = klass
      end

      def alchemy_resource_filters
        [
          {
            name: :by_file_format,
            values: file_formats
          },
          {
            name: :misc,
            values: %w[recent last_upload without_tag deletable]
          }
        ]
      end

      def searchable_alchemy_resource_attributes
        %w[name]
      end

      def searchable_alchemy_resource_associations
        %w[image_file_blob]
      end

      def last_upload
        last_picture = Picture.last
        return Picture.all unless last_picture

        Picture.where(upload_hash: last_picture.upload_hash)
      end

      private

      def file_formats
        ActiveStorage::Blob.joins(:attachments).merge(
          ActiveStorage::Attachment.where(record_type: name)
        ).distinct.pluck(:content_type)
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
    rescue ::ActiveStorage::Error => e
      log_warning(e.message)
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
        format: image_file_format || "jpg",
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

    # Returns a Hash suitable for jquery fileupload json.
    #
    def to_jq_upload
      {
        name: image_file_name,
        size: image_file_size,
        error: errors[:image_file].join
      }
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

    # Returns a humanized, readable name from image filename.
    #
    def humanized_name
      return "" if image_file_name.blank?

      convert_to_humanized_name(image_file_name, image_file_extension)
    end

    # Returns the format the image should be rendered with
    #
    # Only returns a format differing from original if an +image_output_format+
    # is set in config and the image has a convertible file format.
    #
    def default_render_format
      if convertible?
        Config.get(:image_output_format)
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
      Config.get(:image_output_format) &&
        Config.get(:image_output_format) != "original" &&
        has_convertible_format?
    end

    # Returns true if the image can be converted into other formats
    #
    def has_convertible_format?
      image_file&.variable?
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

    # Returns true if picture is not assigned to any Picture ingredient.
    #
    def deletable?
      picture_ingredients.empty?
    end

    def image_file_name
      image_file&.filename&.to_s
    end

    def image_file_format
      image_file&.content_type
    end

    def image_file_size
      image_file&.byte_size
    end

    def image_file_width
      image_file&.metadata&.fetch(:width, nil)
    end

    def image_file_height
      image_file&.metadata&.fetch(:height, nil)
    end

    def image_file_extension
      image_file&.filename&.extension&.downcase
    end

    alias_method :suffix, :image_file_extension
    deprecate suffix: :image_file_extension, deprecator: Alchemy::Deprecation

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

    def image_file_type_allowed
      allowed_filetypes = Config
        .get(:uploader)
        .dig("allowed_filetypes", "alchemy/pictures") || []
      unless image_file_extension&.in?(allowed_filetypes)
        errors.add(:image_file, Alchemy.t("not a valid image"))
      end
    end

    def image_file_not_too_big
      maximum = Config.get(:uploader)["file_size_limit"]&.megabytes
      return true unless maximum

      if image_file_size > maximum
        errors.add(:file, :too_big)
      end
    end
  end
end
