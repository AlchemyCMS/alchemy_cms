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
    before_save :fix_crop_values
    before_save :replace_newlines

    def preview_text(max=30)
      return "" if picture.nil?
      picture.name.to_s[0..max-1]
    end

    # Returns a hash suitable for the js image cropper.
    #
    def cropping_mask
      crop_from = self.crop_from.split('x')
      crop_size = self.crop_size.split('x')
      {
        x1: crop_from[0].to_i,
        y1: crop_from[1].to_i,
        x2: crop_from[0].to_i + crop_size[0].to_i,
        y2: crop_from[1].to_i + crop_size[1].to_i
      }
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

    def replace_newlines
      return nil if caption.nil?
      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end

  end
end
