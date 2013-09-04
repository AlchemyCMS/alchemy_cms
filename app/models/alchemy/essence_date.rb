module Alchemy
  class EssenceDate < ActiveRecord::Base

    attr_accessible :date

    acts_as_essence(
      :ingredient_column => :date
    )

    # Returns self.date for the Element#preview_text method.
    def preview_text
      return "" if date.blank?
      ::I18n.l(date, :format => :date)
    end

  end
end
