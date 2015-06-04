module Alchemy
  class ElementToPage
    def self.table_name
      [Element.table_name, Page.table_name].join('_')
    end
  end
end
