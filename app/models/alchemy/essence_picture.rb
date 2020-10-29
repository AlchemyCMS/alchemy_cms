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

    serialize :render_gravity, JSON
    validate :validate_render_gravity

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

      {
        format: picture.default_render_format,
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

      crop = crop_values_present? || content.settings[:crop]
      size = render_size || content.settings[:size]

      options = {
        size: thumbnail_size(size, crop),
        crop: !!crop,
        crop_from: crop_from.presence,
        crop_size: crop_size.presence,
        flatten: true,
        format: picture.image_file_format,
      }

      picture.url(options) || "alchemy/missing-image.svg"
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

    # Returns the gravity that will be used in render with correct fallbacks etc.
    # Gravity is used when adjusting cropping masks, see transformations.
    # But can also have a general use in aligning background-images with dynamic aspect ratio etc.
    #
    def gravity(gravity_override = nil)
      g = default_gravity

      # settings_gravity = true would leave default gravity but allow users to edit it in essence_picture/edit
      settings_gravity = content.settings[:gravity] == true ? nil : content.settings[:gravity]

      # Here we allow gravity to be overwritten in correct order of priority
      # First we started with default_gravity above.
      # render_gravity comes from db, gravity_override from render
      [settings_gravity, render_gravity, gravity_override].each do |gravity|
        next if gravity.blank?

        if gravity.is_a?(Hash)
          g = g.merge(gravity.symbolize_keys)
        else
          raise ArgumentError, "Gravity not a hash"
        end
      end

      g.each do |key, val|
        unless available_gravities[key]&.include?(val)
          raise ArgumentError, "Invalid gravity option: #{key}: #{val}"
        end
      end

      g
    end

    # Default size gravity is set to "grow" because:
    #
    # 1. It usually makes sense to show as much as possible of an image.
    # Lets say the user uploads a perfectly fine 4:3 image and is then forced to crop it to 16:9
    # as per defined settings. Then in some place you want to render it in 4:3 again => use original.
    # If the user specifically cropped an image down to hide something => use gravity = shrink instead.
    #
    # 2. If the user has not applied a cropping mask, the original image should be center cropped to fit
    # size aspect ratio, ignoring the boundaries of the rendered cropping mask => this equates to "grow".
    #
    def default_gravity
      { size: "grow", x: "center", y: "center"}
    end

    # Available gravities are used to validate gravity method input
    #
    def available_gravities
      {
        size: ["grow", "shrink", "closest_fit"],
        x: ["left", "center", "right"],
        y: ["top", "center", "bottom"],
      }
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

    private

    def fix_crop_values
      %i(crop_from crop_size).each do |crop_value|
        if self[crop_value].is_a?(String)
          write_attribute crop_value, normalize_crop_value(crop_value)
        end
      end
    end

    def validate_render_gravity
      return if render_gravity.blank?

      # Gravity method validates gravity
      begin
        gravity
      rescue ArgumentError
        errors.add(:render_gravity, :invalid)
      end
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
