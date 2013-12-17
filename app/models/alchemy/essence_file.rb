# == Schema Information
#
# Table name: alchemy_essence_files
#
#  id            :integer          not null, primary key
#  attachment_id :integer
#  title         :string(255)
#  css_class     :string(255)
#  creator_id    :integer
#  updater_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Alchemy
  class EssenceFile < ActiveRecord::Base
    belongs_to :attachment
    acts_as_essence ingredient_column: 'attachment'

    def attachment_url
      return if attachment.nil?
      routes.download_attachment_path(id: attachment.id, name: attachment.file_name)
    end

    def preview_text(max=30)
      return "" if attachment.blank?
      attachment.name.to_s[0..max-1]
    end

    private

    def routes
      @routes ||= Engine.routes.url_helpers
    end

  end
end
