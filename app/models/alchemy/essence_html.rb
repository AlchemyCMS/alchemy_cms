# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_htmls
#
#  id         :integer          not null, primary key
#  source     :text
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Alchemy
  class EssenceHtml < BaseRecord
    acts_as_essence ingredient_column: 'source'

    # Returns the first x (default = 30) (HTML escaped) characters from self.source for the Element#preview_text method.
    def preview_text(maxlength = 30)
      ::CGI.escapeHTML(source.to_s)[0..maxlength]
    end
  end
end
