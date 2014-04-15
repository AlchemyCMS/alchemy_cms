require 'acts-as-taggable-on'
require 'dragonfly'

module Alchemy
  class Picture < ActiveRecord::Base
    include Alchemy::NameConversions

    has_many :essence_pictures, :class_name => 'Alchemy::EssencePicture', :foreign_key => 'picture_id'
    has_many :contents, :through => :essence_pictures
    has_many :elements, :through => :contents
    has_many :pages, :through => :elements

    # Raise error, if picture is in use (aka. assigned to an EssencePicture)
    #
    # === CAUTION:
    # This HAS to be placed for Dragonfly's class methods, to ensure this runs before Dragonfly's before_destroy callback.
    #
    before_destroy :unless => :deletable? do
      raise PictureInUseError, I18n.t(:cannot_delete_picture_notice) % { :name => name }
    end

    image_accessor :image_file do
      if Config.get(:preprocess_image_resize).present?
        after_assign { |a| a.process!(:resize, "#{Config.get(:preprocess_image_resize)}>") }
      end
    end

    validates_presence_of :image_file
    validates_size_of :image_file, :maximum => Config.get(:uploader)['file_size_limit'].megabytes
    validates_property :format, :of => :image_file, :in => Config.get(:uploader)['allowed_filetypes']['pictures'], :case_sensitive => false, :message => I18n.t("not a valid image")

    acts_as_taggable

    attr_accessible(
      :image_file,
      :name,
      :tag_list,
      :upload_hash
    )

    stampable stamper_class_name: Alchemy.user_class_name

    scope :recent, where("#{self.table_name}.created_at > ?", Time.now-24.hours).order(:created_at)
    scope :deletable, where("alchemy_pictures.id NOT IN (SELECT picture_id FROM alchemy_essence_pictures)")
    scope :without_tag, where("cached_tag_list IS NULL OR cached_tag_list = ''")

    # Class methods

    class << self

      def find_paginated(params, per_page)
        Picture.where("name LIKE ?", "%#{params[:query]}%").page(params[:page] || 1).per(per_page).order(:name)
      end

      def last_upload
        last_picture = Picture.last
        return Picture.scoped unless last_picture
        Picture.where(:upload_hash => last_picture.upload_hash)
      end

      def filtered_by(filter = '')
        case filter
          when 'recent'      then recent
          when 'last_upload' then last_upload
          when 'without_tag' then without_tag
        else
          scoped
        end
      end

    end

    # Instance methods

    def urlname
      if self.name.blank?
        "image_#{self.id}"
      else
        ::CGI.escape(self.name.gsub(/\.(gif|png|jpe?g|tiff?)/i, '').gsub(/\./, ' '))
      end
    end

    def suffix
      image_file.ext
    end

    def humanized_name
      return "" if image_file_name.blank?
      convert_to_humanized_name(image_file_name, suffix)
    end

    # Returning true if picture's width is greater than it's height
    def landscape_format?
      image_file.landscape?
    end
    alias_method :landscape?, :landscape_format?

    # Returning true if picture's width is smaller than it's height
    def portrait_format?
      image_file.portrait?
    end
    alias_method :portrait?, :portrait_format?

    # Returning true if picture's width and height is equal
    def square_format?
      image_file.aspect_ratio == 1.0
    end
    alias_method :square?, :square_format?

    # Returns the default centered image mask for a given size
    def default_mask(size)
      raise "No size given" if size.blank?
      width = size.split('x')[0].to_i
      height = size.split('x')[1].to_i
      if (width > height)
        zoom_factor = image_file_width.to_f / width
        mask_height = (height * zoom_factor).round
        x1 = 0
        x2 = image_file_width
        y1 = (image_file_height - mask_height) / 2
        y2 = y1 + mask_height
      elsif (width == 0 && height == 0)
        x1 = 0
        x2 = image_file_width
        y1 = 0
        y2 = image_file_height
      else
        zoom_factor = image_file_height.to_f / height
        mask_width = (width * zoom_factor).round
        x1 = (image_file_width - mask_width) / 2
        x2 = x1 + mask_width
        y1 = 0
        y2 = image_file_height
      end
      {
        :x1 => x1,
        :y1 => y1,
        :x2 => x2,
        :y2 => y2
      }
    end

    def cropped_thumbnail_size(size)
      return "111x93" if size == "111x93" || size.blank?
      x = size.split('x')[0].to_i
      y = size.split('x')[1].to_i
      return "111x93" if x.zero? || y.zero?
      if (x > y)
        zoom_factor = 111.0 / x
        new_x = 111
        new_y = y * zoom_factor
      else
        zoom_factor = 93.0 / y
        new_x = x * zoom_factor
        new_y = 93
      end
      "#{new_x.round}x#{new_y.round}"
    end

    # Checks if the picture is restricted, because it is attached on restricted pages only
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    def deletable?
      !essence_pictures.any?
    end

    def image_file_dimensions
      "#{image_file_width} x #{image_file_height}"
    end

    # Returns a security token for signed picture rendering requests.
    #
    # Pass a params hash containing:
    #
    #   size       [String]  (Optional)
    #   crop       [Boolean] (Optional)
    #   crop_from  [String]  (Optional)
    #   crop_size  [String]  (Optional)
    #   quality    [Integer] (Optional)
    #
    # to sign them.
    #
    def security_token(params = {})
      @params = params.stringify_keys
      @params.update({'crop' => @params['crop'] ? 'crop' : nil, 'id' => self.id})
      @params.delete_if { |k,v| v.nil? }
      PictureAttributes.secure(@params)
    end

  end
end
