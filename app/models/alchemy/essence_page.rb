# frozen_string_literal: true

module Alchemy
  class EssencePage < BaseRecord
    acts_as_essence(
      ingredient_column: :page,
      preview_text_method: :name,
      belongs_to: {
        class_name: "Alchemy::Page",
        foreign_key: :page_id,
        inverse_of: :essence_pages,
        optional: true,
      },
    )
  end
end
