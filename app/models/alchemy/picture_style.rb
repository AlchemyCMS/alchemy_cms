# == Schema Information
#
# Table name: alchemy_picture_styles
#
#  id                    :integer          not null, primary key
#  picture_assignment_id :integer
#  crop_from             :string
#  crop_size             :string
#  render_size           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  creator_id            :integer
#  updater_id            :integer
#

module Alchemy
  class PictureStyle < ActiveRecord::Base
    include Alchemy::Picture::Transformations

    belongs_to :picture_assignment
    has_one :picture, through: :picture_assignment

    before_save :fix_crop_values

    delegate :image_file_width, :image_file_height, :image_file, to: :picture

    # The url to show the picture style.
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
    def url(options = {})
      routes.show_picture_path(url_params(options))
    end

    # A Hash of coordinates suitable for the graphical image cropper.
    #
    def cropping_mask
      return if crop_from.blank? || crop_size.blank?
      crop_from = point_from_string(read_attribute(:crop_from))
      crop_size = sizes_from_string(read_attribute(:crop_size))

      point_and_mask_to_points(crop_from, crop_size)
    end

    def crop?
      crop_size.present? && crop_from.present?
    end

    def essence
      @essence ||= picture_assignment.assignable
    end

    def content
      @content ||= essence.content
    end

    private

    def fix_crop_values
      %w(crop_from crop_size).each do |crop_value|
        write_attribute crop_value, normalize_crop_value(crop_value)
      end
    end

    def normalize_crop_value(crop_value)
      self.send(crop_value).to_s.split('x').map { |n| normalize_number(n) }.join('x')
    end

    def normalize_number(number)
      number = number.to_f.round
      number < 0 ? 0 : number
    end

    def url_params(options = {})
      params = picture_params.merge(options)
      params = params.merge(crop_params)

      params = sanitized_url_params(params)
      params.merge(security_token_param(params))
    end

    def sanitized_url_params(params)
      params[:crop] = 'crop' if params[:crop] == true
      params[:size] = params.delete(:image_size) if params[:image_size]
      secure_attributes = PictureAttributes::SECURE_ATTRIBUTES.dup
      secure_attributes += %w(name format sh)
      params.delete_if { |k, v| !secure_attributes.include?(k.to_s) || v.blank? }
    end

    def picture_params
      { id: picture.id, name: picture.urlname, format: Config.get(:image_output_format) }
    end

    def crop_params
      return {} unless crop_from.present? && crop_size.present?
      { crop: 'crop', crop_from: crop_from, crop_size: crop_size }
    end

    def security_token_param(params)
      { sh: picture.security_token(params) }
    end

    # Returns Alchemy's url helpers.
    def routes
      @routes ||= Engine.routes.url_helpers
    end
  end
end
