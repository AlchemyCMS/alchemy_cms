module Alchemy
  class Picture < ActiveRecord::Base

    has_many :essence_pictures, :class_name => 'Alchemy::EssencePicture', :foreign_key => 'picture_id'
    has_many :contents, :through => :essence_pictures
    has_many :elements, :through => :contents
    has_many :pages, :through => :elements

    # acts_as_fleximage do
    #   require_image true
    #   missing_image_message I18n.t("missing_image")
    #   invalid_image_message I18n.t("not a valid image")
    #   unless Config.get(:preprocess_image_resize).blank?
    #     preprocess_image do |image|
    #       image.resize Config.get(:preprocess_image_resize)
    #     end
    #   end
    # end

    image_accessor :image_file do
      storage_path :image_storage_path
    end

    # TODO: Write task for converting image store format to new one. Escpecially because of id based file storage of fleximage.

    acts_as_taggable

    attr_accessible(
      :image_file,
      :name,
      :tag_list,
      :upload_hash
    )

    stampable(:stamper_class_name => 'Alchemy::User')

    scope :recent, where("#{self.table_name}.created_at > ?", Time.now-24.hours).order(:created_at)

    def self.find_paginated(params, per_page)
      Picture.where("name LIKE ?", "%#{params[:query]}%").page(params[:page] || 1).per(per_page).order(:name)
    end

    def self.last_upload
      last_picture = Picture.last
      return Picture.scoped unless last_picture
      Picture.where(:upload_hash => last_picture.upload_hash)
    end

    # Returning the filepath relative to Rails.root public folder.
    def public_file_path
      self.file_path.gsub("#{::Rails.root}/public", '')
    end

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
      (image_file_name.downcase.gsub(/\.#{::Regexp.quote(suffix)}$/, '')).humanize
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

    # Returns a security token for signed picture rendering requests.
    #
    # Pass a params hash containing:
    #
    #   size       [String]  (Optional)
    #   crop       [Boolean] (Optional)
    #   crop_from  [String]  (Optional)
    #   crop_size  [String]  (Optional)
    #
    # to sign them.
    #
    def security_token(params = {})
      @params = params.stringify_keys
      @params.update({'crop' => @params['crop'] ? 'crop' : nil})
      Digest::SHA1.hexdigest(secured_params)[0..15]
    end

  private

    def secured_params
      secret = Rails.configuration.secret_token
      [id, @params['size'], @params['crop'], @params['crop_from'], @params['crop_size'], secret].join('-')
    end

    def image_storage_path
      now = Time.now
      File.join(now.year.to_s, now.month.to_s, now.day.to_s, image_file_name).to_s
    end

  end
end
