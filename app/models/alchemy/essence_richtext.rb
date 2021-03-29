# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_richtexts
#
#  id            :integer          not null, primary key
#  body          :text
#  stripped_body :text
#  public        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Alchemy
  class EssenceRichtext < BaseRecord
    acts_as_essence preview_text_column: "stripped_body"

    before_save :strip_content
    before_save :sanitize_content

    def has_tinymce?
      true
    end

    private

    def strip_content
      self.stripped_body = Rails::Html::FullSanitizer.new.sanitize(body)
    end

    def sanitize_content
      self.sanitized_body = Rails::Html::SafeListSanitizer.new.sanitize(
        body,
        content_sanitizer_settings
      )
    end

    def content_sanitizer_settings
      content&.settings&.fetch(:sanitizer, {}) || {}
    end
  end
end
