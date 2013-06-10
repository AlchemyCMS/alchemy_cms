module Alchemy
  class EssenceFile < ActiveRecord::Base
    attr_accessible :title, :css_class, :attachment_id
    belongs_to :attachment
    acts_as_essence ingredient_column: 'attachment'

    def preview_text(max=30)
      return "" if attachment.blank?
      attachment.name.to_s[0..max-1]
    end

  end
end
