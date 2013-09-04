require 'alchemy/essence'

module Alchemy
  class EssencePicture < ActiveRecord::Base

    attr_accessible(
      :caption,
      :title,
      :alt_tag,
      :link,
      :link_class_name,
      :link_title,
      :css_class,
      :link_target,
      :crop_from,
      :crop_size,
      :render_size,
      :picture_id
    )

    acts_as_essence ingredient_column: 'picture'

    belongs_to :picture
    before_save :fix_crop_values
    before_save :replace_newlines

    def preview_text(max=30)
      return "" if picture.nil?
      picture.name.to_s[0..max-1]
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
