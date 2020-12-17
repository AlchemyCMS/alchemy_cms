# frozen_string_literal: true

module Alchemy
  class PageVersion < BaseRecord
    belongs_to :page, class_name: "Alchemy::Page", inverse_of: :versions

    has_many :elements, -> { order(:position) },
      class_name: "Alchemy::Element",
      inverse_of: :page_version

    scope :drafts, -> { where(public_on: nil).order(updated_at: :desc) }

    # All published versions
    #
    def self.published(on: Time.current)
      where("#{table_name}.public_on <= :time AND " \
            "(#{table_name}.public_until IS NULL " \
            "OR #{table_name}.public_until >= :time)", time: on).order(public_on: :desc)
    end
  end
end
