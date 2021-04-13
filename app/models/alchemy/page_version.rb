# frozen_string_literal: true

module Alchemy
  class PageVersion < BaseRecord
    belongs_to :page, class_name: "Alchemy::Page", inverse_of: :versions

    has_many :elements, -> { order(:position) },
      class_name: "Alchemy::Element",
      inverse_of: :page_version

    scope :drafts, -> { where(public_on: nil).order(updated_at: :desc) }
    scope :published, -> { where.not(public_on: nil).order(public_on: :desc) }

    def self.public_on(time = Time.current)
      where("#{table_name}.public_on <= :time AND " \
            "(#{table_name}.public_until IS NULL " \
            "OR #{table_name}.public_until >= :time)", time: time)
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
      ElementsRepository.new(elements.includes({ contents: :essence }, :tags))
    end

    private

    def delete_elements
      DeleteElements.new(elements).call
    end
  end
end
