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
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  crop_from       :string
#  crop_size       :string
#  render_size     :string
#

module Alchemy
  class EssencePicture < BaseRecord
    acts_as_essence ingredient_column: :picture, belongs_to: {
      class_name: "Alchemy::Picture",
      foreign_key: :picture_id,
      inverse_of: :essence_pictures,
      optional: true,
    }

    delegate :image_file_width, :image_file_height, :image_file, to: :picture, allow_nil: true
    before_save :fix_crop_values
    before_save :replace_newlines

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

      picture.url(picture_url_options.merge(options)) || "missing-image.png"
    end

    # Picture rendering options
    #
    # Returns the +default_render_format+ of the associated +Alchemy::Picture+
    # together with the +crop_from+ and +crop_size+ values
    #
    # @return [HashWithIndifferentAccess]
    def picture_url_options
      return {} if picture.nil?

      crop = crop_values_present? || content.settings[:crop]

      {
        format: picture.default_render_format,
        crop: !!crop,
        crop_from: crop_from.presence,
        crop_size: crop_size.presence,
        size: content.settings[:size],
      }.with_indifferent_access
    end

    # Returns an url for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [String]
    def thumbnail_url
      return if picture.nil?

      picture.url(thumbnail_url_options) || "alchemy/missing-image.svg"
    end

    # Thumbnail rendering options
    #
    # @return [HashWithIndifferentAccess]
    def thumbnail_url_options
      crop = crop_values_present? || content.settings[:crop]

      {
        size: "160x120",
        crop: !!crop,
        crop_from: crop_from.presence || default_crop_from&.join("x"),
        crop_size: crop_size.presence || default_crop_size&.join("x"),
        flatten: true,
        format: picture&.image_file_format || "jpg",
      }
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

    # Returns a serialized ingredient value for json api
    #
    # @return [String]
    def serialized_ingredient
      picture_url(content.settings)
    end

    # Show image cropping link for content
    def allow_image_cropping?
      content && content.settings[:crop] && picture &&
        picture.can_be_cropped_to?(
          content.settings[:size],
          content.settings[:upsample],
        ) && !!picture.image_file
    end

    def crop_values_present?
      crop_from.present? && crop_size.present?
    end

    # Settings for the graphical JS image cropper
    def image_cropper_settings
      Alchemy::ImageCropperSettings.new(
        render_size: point_from_string(render_size.presence || content.settings[:size]),
        default_crop_from: default_crop_from,
        default_crop_size: default_crop_size,
        fixed_ratio: content.settings[:fixed_ratio],
        image_width: picture&.image_file_width,
        image_height: picture&.image_file_height,
      ).to_h
    end

    private

    def fix_crop_values
      %i(crop_from crop_size).each do |crop_value|
        if self[crop_value].is_a?(String)
          write_attribute crop_value, normalize_crop_value(crop_value)
        end
      end
    end

    def default_crop_size
      return nil if !content.settings[:crop]
      return nil if !content.settings[:size]

      mask = content.settings[:size].split("x").map(&:to_f)
      zoom = [
        mask[0] / (image_file_width || 1),
        mask[1] / (image_file_height || 1),
      ].max

      [(mask[0] / zoom), (mask[1] / zoom)].map(&:round)
    end

    def default_crop_from
      return nil unless content.settings[:crop]
      return nil if default_crop_size.nil?

      [
        ((image_file_width || 0) - default_crop_size[0]) / 2,
        ((image_file_height || 0) - default_crop_size[1]) / 2,
      ].map(&:round)
    end

    def point_from_string(string)
      return if string.nil?
      string.split("x", 2).map(&:to_i)
    end

    def normalize_crop_value(crop_value)
      self[crop_value].split("x").map { |n| normalize_number(n) }.join("x")
    end

    def normalize_number(number)
      number = number.to_f.round
      number.negative? ? 0 : number
    end

    def replace_newlines
      return nil if caption.nil?

      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end
  end
end
