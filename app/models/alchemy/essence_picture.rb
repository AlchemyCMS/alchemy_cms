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
