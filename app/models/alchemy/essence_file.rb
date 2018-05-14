# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_files
#
#  id            :integer          not null, primary key
#  attachment_id :integer
#  title         :string
#  css_class     :string
#  creator_id    :integer
#  updater_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  link_text     :string
#

module Alchemy
  class EssenceFile < BaseRecord
    belongs_to :attachment, optional: true
    acts_as_essence ingredient_column: 'attachment'

    def attachment_url
      return if attachment.nil?
      routes.download_attachment_path(
        id: attachment.id,
        name: attachment.urlname,
        format: attachment.suffix
      )
    end

    def preview_text(max = 30)
      return "" if attachment.blank?
      attachment.name.to_s[0..max - 1]
    end

    # Returns a serialized ingredient value for json api
    def serialized_ingredient
      attachment_url
    end

    private

    def routes
      @routes ||= Engine.routes.url_helpers
    end
  end
end
