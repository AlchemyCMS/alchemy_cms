# frozen_string_literal: true

module Alchemy
  class PageVersion < BaseRecord
    belongs_to :page, class_name: "Alchemy::Page", inverse_of: :versions

    has_many :elements, -> { order(:position) },
      class_name: "Alchemy::Element",
      inverse_of: :page_version
  end
end
