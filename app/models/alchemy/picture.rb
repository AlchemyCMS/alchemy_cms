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
      large: "240x180",
    }.with_indifferent_access.freeze

    CONVERTIBLE_FILE_FORMATS = %w(gif jpg jpeg png).freeze

    TRANSFORMATION_OPTIONS = [
      :crop,
      :crop_from,
      :crop_size,
      :flatten,
      :format,
      :quality,
      :size,
      :upsample,
    ]

    include Alchemy::Logger
    include Alchemy::NameConversions
    include Alchemy::Taggable
    include Alchemy::TouchElements
    include Calculations

    has_many :essence_pictures,
      class_name: "Alchemy::EssencePicture",
      foreign_key: "picture_id",
      inverse_of: :ingredient_association

    has_many :contents, through: :essence_pictures
    has_many :elements, through: :contents
    has_many :pages, through: :elements
    has_many :thumbs, class_name: "Alchemy::PictureThumb", dependent: :destroy

    # Raise error, if picture is in use (aka. assigned to an EssencePicture)
    #
    # === CAUTION
    #
    # This HAS to be placed for Dragonfly's class methods,
    # to ensure this runs before Dragonfly's before_destroy callback.
    #
    before_destroy unless: :deletable? do
      raise PictureInUseError, Alchemy.t(:cannot_delete_picture_notice) % { name: name }
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

    # Enables Dragonfly image processing
    dragonfly_accessor :image_file, app: :alchemy_pictures do
      # Preprocess after uploading the picture
      after_assign do |image|
        if has_convertible_format?
          self.class.preprocessor_class.new(image).call
        end
      end
    end

    # Create important thumbnails upfront
    after_create -> { PictureThumb.generate_thumbs!(self) if has_convertible_format? }

    # We need to define this method here to have it available in the validations below.
    class << self
      def allowed_filetypes
        Config.get(:uploader).fetch("allowed_filetypes", {}).fetch("alchemy/pictures", [])
      end
    end

    validates_presence_of :image_file
    validates_size_of :image_file, maximum: Config.get(:uploader)["file_size_limit"].megabytes
    validates_property :format,
      of: :image_file,
      in: allowed_filetypes,
      case_sensitive: false,
      message: Alchemy.t("not a valid image")

    stampable stamper_class_name: Alchemy.user_class_name

    scope :named, ->(name) { where("#{table_name}.name LIKE ?", "%#{name}%") }
    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :deletable, -> { where("#{table_name}.id NOT IN (SELECT picture_id FROM #{EssencePicture.table_name})") }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: { id: nil }) }

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

      def searchable_alchemy_resource_attributes
        %w(name image_file_name)
      end

      def last_upload
        last_picture = Picture.last
        return Picture.all unless last_picture

        Picture.where(upload_hash: last_picture.upload_hash)
      end

      def search_by(params, query, per_page = nil)
        pictures = query.result

        if params[:tagged_with].present?
          pictures = pictures.tagged_with(params[:tagged_with])
        end

        if params[:filter].present?
          pictures = pictures.filtered_by(params[:filter])
        end

        if per_page
          pictures = pictures.page(params[:page] || 1).per(per_page)
        end

        pictures.order(:name)
      end

      def filtered_by(filter = "")
        case filter
        when "recent" then recent
        when "last_upload" then last_upload
        when "without_tag" then without_tag
        else
          all
        end
      end
    end

    # Instance methods

    # Returns an url (or relative path) to a processed image for use inside an image_tag helper.
    #
    # Any additional options are passed to the url method, so you can add params to your url.
    #
    # Example:
    #
    #   <%= image_tag picture.url(size: '320x200', format: 'png') %>
    #
    # @see Alchemy::PictureVariant#call for transformation options
    # @see Alchemy::Picture::Url#call for url options
    # @return [String|Nil]
    def url(options = {})
      return unless image_file

      variant = PictureVariant.new(self, options.slice(*TRANSFORMATION_OPTIONS))
      self.class.url_class.new(variant).call(
        options.except(*TRANSFORMATION_OPTIONS).merge(
          basename: name,
          ext: variant.render_format,
          name: name,
        )
      )
    rescue ::Dragonfly::Job::Fetch::NotFound => e
      log_warning(e.message)
      nil
    end

    def previous(params = {})
      query = Picture.ransack(params[:q])
      Picture.search_by(params, query).where("name < ?", name).last
    end

    def next(params = {})
      query = Picture.ransack(params[:q])
      Picture.search_by(params, query).where("name > ?", name).first
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
        error: errors[:image_file].join,
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

    # Returns the suffix of the filename.
    #
    def suffix
      image_file.ext
    end

    # Returns a humanized, readable name from image filename.
    #
    def humanized_name
      return "" if image_file_name.blank?

      convert_to_humanized_name(image_file_name, suffix)
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
        image_file_format
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
      image_file_format.in?(CONVERTIBLE_FILE_FORMATS)
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

    # Returns true if picture is not assigned to any EssencePicture.
    #
    def deletable?
      essence_pictures.empty?
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
  end
end
