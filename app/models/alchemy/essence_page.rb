# frozen_string_literal: true

module Alchemy
  class EssencePage < BaseRecord
    acts_as_essence(
      ingredient_column: :page,
      preview_text_method: :name
    )

    belongs_to :page, class_name: 'Alchemy::Page', optional: true

    def ingredient=(page)
      case page
      when /\d/
        self.page = Alchemy::Page.new(id: page)
      when Alchemy::Page
        self.page = page
      else
        super
      end
    end
  end
end
