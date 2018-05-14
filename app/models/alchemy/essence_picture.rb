# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_pictures
#
#  id              :integer          not null, primary key
#  picture_id      :integer
#  caption         :string
#  title           :string
#  alt_tag         :string
#  link            :string
#  link_class_name :string
#  link_title      :string
#  css_class       :string
#  link_target     :string
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  crop_from       :string
#  crop_size       :string
#  render_size     :string
#

module Alchemy
  class EssencePicture < BaseRecord
    acts_as_essence ingredient_column: 'picture'

    belongs_to :picture, optional: true
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
    # @return [String]
    def picture_url(options = {})
      return if picture.nil?

      picture.url picture_url_options.merge(options)
    end

    # Picture rendering options
    #
    # Returns the +default_render_format+ of the associated +Alchemy::Picture+
    # together with the +crop_from+ and +crop_size+ values
    #
    # @return [HashWithIndifferentAccess]
    def picture_url_options
      return {} if picture.nil?

      {
        format: picture.default_render_format,
        crop_from: crop_from.presence,
        crop_size: crop_size.presence
      }.with_indifferent_access
    end

    # Returns an url for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [String]
    def thumbnail_url(options = {})
      return if picture.nil?

      crop = crop_values_present? || content.settings_value(:crop, options)
      size = render_size || content.settings_value(:size, options)

      options = {
        size: thumbnail_size(size, crop),
        crop: !!crop,
        crop_from: crop_from.presence,
        crop_size: crop_size.presence,
        flatten: true,
        format: picture.image_file_format
      }

      picture.url(options)
    end

    # The name of the picture used as preview text in element editor views.
    #
    # @param max [Integer]
    #   The maximum length of the text returned.
    #
    # @return [String]
    def preview_text(max = 30)
      return "" if picture.nil?
      picture.name.to_s[0..max - 1]
    end

    # A Hash of coordinates suitable for the graphical image cropper.
    #
    # @return [Hash]
    def cropping_mask
      return if crop_from.blank? || crop_size.blank?
      crop_from = point_from_string(read_attribute(:crop_from))
      crop_size = sizes_from_string(read_attribute(:crop_size))

      point_and_mask_to_points(crop_from, crop_size)
    end

    # Returns a serialized ingredient value for json api
    #
    # @return [String]
    def serialized_ingredient
      picture_url(content.settings)
    end

    # Show image cropping link for content and options?
    def allow_image_cropping?(options = {})
      content && content.settings_value(:crop, options) && picture &&
        picture.can_be_cropped_to(
          content.settings_value(:size, options),
          content.settings_value(:upsample, options)
        )
    end

    def crop_values_present?
      crop_from.present? && crop_size.present?
    end

    private

    def fix_crop_values
      %i(crop_from crop_size).each do |crop_value|
        if self[crop_value].is_a?(String)
          write_attribute crop_value, normalize_crop_value(crop_value)
        end
      end
    end

    def normalize_crop_value(crop_value)
      self[crop_value].split('x').map { |n| normalize_number(n) }.join('x')
    end

    def normalize_number(number)
      number = number.to_f.round
      number < 0 ? 0 : number
    end

    def replace_newlines
      return nil if caption.nil?
      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end
  end
end
