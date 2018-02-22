# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_richtexts
#
#  id            :integer          not null, primary key
#  body          :text
#  stripped_body :text
#  public        :boolean
#  creator_id    :integer
#  updater_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Alchemy
  class EssenceRichtext < BaseRecord
    acts_as_essence preview_text_column: 'stripped_body'

    before_save :strip_content

    def has_tinymce?
      true
    end

    private

    def strip_content
      self.stripped_body = Rails::Html::FullSanitizer.new.sanitize(body)
    end
  end
end
