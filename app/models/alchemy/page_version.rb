# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_page_versions
#
#  id               :integer          not null, primary key
#  meta_description :text
#  meta_keywords    :text
#  public_on        :datetime
#  public_until     :datetime
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  page_id          :integer          not null
#
# Indexes
#
#  index_alchemy_page_versions_on_page_id                     (page_id)
#  index_alchemy_page_versions_on_public_on_and_public_until  (public_on,public_until)
#
# Foreign Keys
#
#  page_id  (page_id => alchemy_pages.id) ON DELETE => cascade
#
module Alchemy
  class PageVersion < BaseRecord
    include Alchemy::Publishable

    # Metadata attributes that are versioned (moved from Page)
    METADATA_ATTRIBUTES = %w[
      title
      meta_description
      meta_keywords
    ].freeze

    belongs_to :page, class_name: "Alchemy::Page", inverse_of: :versions, touch: true

    has_many :elements, -> { order(:position) },
      class_name: "Alchemy::Element",
      inverse_of: :page_version

    before_create :set_title_from_page

    class << self
      alias_method :drafts, :draft
      deprecate drafts: :draft, deprecator: Alchemy::Deprecation

      alias_method :public_on, :published
      deprecate public_on: :published, deprecator: Alchemy::Deprecation
    end

    before_destroy :delete_elements

    def element_repository
      @element_repository ||= ElementsRepository.new(elements)
    end

    private

    def delete_elements
      DeleteElements.new(elements).call
    end

    def set_title_from_page
      return if title.present?

      self.title = page&.name
    end
  end
end
