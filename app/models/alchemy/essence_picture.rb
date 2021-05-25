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
    include Alchemy::PictureThumbnails

    acts_as_essence ingredient_column: :picture, belongs_to: {
      class_name: "Alchemy::Picture",
      foreign_key: :picture_id,
      inverse_of: :essence_pictures,
      optional: true,
    }

    delegate :settings, to: :content

    before_save :replace_newlines

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

    private

    def replace_newlines
      return nil if caption.nil?

      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end
  end
end
