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

    acts_as_essence(
      :ingredient_column => :picture,
      :preview_text_method => :name
    )

    belongs_to :picture
    before_save :replace_newlines
    before_save :fix_crop_from

    private

    def fix_crop_from
      write_attribute(:crop_from, self.crop_from.to_s.split('x').map { |number| number.to_i < 0 ? "0" : number }.join('x'))
    end

    def replace_newlines
      return nil if caption.nil?
      caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
    end

  end
end
