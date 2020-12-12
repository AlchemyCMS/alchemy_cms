# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_legacy_page_urls
#
#  id         :integer          not null, primary key
#  urlname    :string           not null
#  page_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Alchemy::LegacyPageUrl < ActiveRecord::Base
  belongs_to :page,
    class_name: "Alchemy::Page",
    required: true

  validates :urlname,
    presence: true,
    format: {with: /\A[:\.\w\-+_\/\?&%;=#]*\z/}
end
