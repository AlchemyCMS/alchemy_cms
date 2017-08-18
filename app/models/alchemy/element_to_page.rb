# frozen_string_literal: true

module Alchemy
  class ElementToPage
    def self.table_name
      [Alchemy::Element.table_name, Alchemy::Page.table_name].join('_')
    end
  end
end
