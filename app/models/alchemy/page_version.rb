# frozen_string_literal: true

module Alchemy
  class PageVersion < BaseRecord
    belongs_to :page, class_name: "Alchemy::Page", inverse_of: :versions
  end
end
