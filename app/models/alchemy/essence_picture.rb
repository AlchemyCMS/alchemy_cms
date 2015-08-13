# == Schema Information
#
# Table name: alchemy_essence_pictures
#
#  id              :integer          not null, primary key
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
#

module Alchemy
  class EssencePicture < ActiveRecord::Base
    acts_as_essence ingredient_column: 'picture'

    has_one :picture_assignment, as: :assignable, dependent: :destroy
    has_one :picture, through: :picture_assignment, source: :picture
    has_one :picture_style, through: :picture_assignment

    before_save :replace_newlines

    def picture_id=(id)
      if id.present?
        picture = Picture.find(id)
      else
        picture_assignment.try(:delete)
      end
    end

    def picture_url(options = {})
      picture_style.url(options)
    end

    # The name of the picture used as preview text in element editor views.
    #
    # @param max [Integer]
    #   The maximum length of the text returned.
    #
    def preview_text(max = 30)
      return "" if picture.nil?
      picture.name.to_s[0..max-1]
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

    def replace_newlines
      return nil if caption.nil?
      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end
  end
end
