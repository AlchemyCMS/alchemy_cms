# == Schema Information
#
# Table name: alchemy_essence_dates
#
#  id         :integer          not null, primary key
#  date       :datetime
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Alchemy
  class EssenceDate < ActiveRecord::Base
    acts_as_essence ingredient_column: 'date'

    # Returns self.date for the Element#preview_text method.
    def preview_text(maxlength=nil)
      return "" if date.blank?
      ::I18n.l(date, format: :date)
    end

  end
end
