# frozen_string_literal: true

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

    # Determines if this version is public
    #
    # Takes the two timestamps +public_on+ and +public_until+
    # and returns true if the time given (+Time.current+ per default)
    # is in this timespan.
    #
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def public?(time = Time.current)
      already_public_for?(time) && still_public_for?(time)
    end

    # Determines if this version is already public for given time
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def already_public_for?(time = Time.current)
      !public_on.nil? && public_on <= time
    end

    # Determines if this version is still public for given time
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def still_public_for?(time = Time.current)
      public_until.nil? || public_until >= time
    end

    def element_repository
      ElementsRepository.new(elements)
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
