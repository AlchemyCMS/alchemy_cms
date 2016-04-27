# == Schema Information
#
# Table name: alchemy_essence_pictures
#
#  id              :integer          not null, primary key
#  picture_id      :integer
#  caption         :string(255)
#  title           :string(255)
#  alt_tag         :string(255)
#  link            :string(255)
#  link_class_name :string(255)
#  link_title      :string(255)
#  css_class       :string(255)
#  link_target     :string(255)
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  crop_from       :string(255)
#  crop_size       :string(255)
#  render_size     :string(255)
#

module Alchemy
  class EssencePicture < ActiveRecord::Base
    acts_as_essence ingredient_column: 'picture'

    belongs_to :picture
    delegate :image_file_width, :image_file_height, :image_file, to: :picture
    before_save :fix_crop_values
    before_save :replace_newlines

    include Alchemy::Picture::Transformations

    # The url to show the picture.
    #
    # Takes all values like +name+ and crop sizes (+crop_from+, +crop_size+ from the build in graphical image cropper)
    # and also adds the security token.
    #
    # You typically want to set the size the picture should be resized to.
    #
    # === Example:
    #
    #   essence_picture.picture_url(size: '200x300', crop: true, format: 'gif')
    #   # '/pictures/1/show/200x300/crop/cats.gif?sh=765rfghj'
    #
    # @option options size [String]
    #   The size the picture should be resized to.
    #
    # @option options format [String]
    #   The format the picture should be rendered in.
    #   Defaults to the +image_output_format+ from the +Alchemy::Config+.
    #
    # @option options crop [Boolean]
    #   If set to true the picture will be cropped to fit the size value.
    #
    def picture_url(options = {})
      return if picture.nil?
      routes.show_picture_path(picture_params(options))
    end

    # The name of the picture used as preview text in element editor views.
    #
    # @param max [Integer]
    #   The maximum length of the text returned.
    #
    def preview_text(max = 30)
      return "" if picture.nil?
      picture.name.to_s[0..max - 1]
    end

    # A Hash of coordinates suitable for the graphical image cropper.
    #
    def cropping_mask
      return if crop_from.blank? || crop_size.blank?
      crop_from = point_from_string(read_attribute(:crop_from))
      crop_size = sizes_from_string(read_attribute(:crop_size))

      point_and_mask_to_points(crop_from, crop_size)
    end

    # Returns a serialized ingredient value for json api
    def serialized_ingredient
      picture_url(content.settings)
    end

    # Show image cropping link for content and options?
    def allow_image_cropping?(options = {})
      content && content.settings_value(:crop, options) && picture &&
        picture.can_be_cropped_to(
          content.settings_value(:image_size, options),
          content.settings_value(:upsample, options)
        )
    end

    private

    def fix_crop_values
      %w(crop_from crop_size).each do |crop_value|
        write_attribute crop_value, normalize_crop_value(crop_value)
      end
    end

    def normalize_crop_value(crop_value)
      send(crop_value).to_s.split('x').map { |n| normalize_number(n) }.join('x')
    end

    def normalize_number(number)
      number = number.to_f.round
      number < 0 ? 0 : number
    end

    def replace_newlines
      return nil if caption.nil?
      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end

    # Returns Alchemy's url helpers.
    def routes
      @routes ||= Engine.routes.url_helpers
    end

    # Params for picture_path and picture_url methods
    #
    # @see +picture_url+ for options
    #
    def picture_params(options = {})
      return {} if picture.nil?

      params = {
        id: picture.id,
        name: picture.urlname,
        format: picture.default_render_format
      }.merge(options)

      if options[:crop] && crop_from.present? && crop_size.present?
        params = {
          crop: true,
          crop_from: crop_from,
          crop_size: crop_size
        }.merge(params)
      end

      params = clean_picture_params(params)
      params.merge(sh: picture.security_token(params))
    end

    # Ensures correct and clean params for show picture path.
    #
    def clean_picture_params(params)
      if params[:crop] == true
        params[:crop] = 'crop'
      end
      if params[:image_size]
        params[:size] = params.delete(:image_size)
      end
      secure_attributes = PictureAttributes::SECURE_ATTRIBUTES.dup
      secure_attributes += %w(name format sh)
      params.delete_if { |k, v| !secure_attributes.include?(k.to_s) || v.blank? }
    end
  end
end
