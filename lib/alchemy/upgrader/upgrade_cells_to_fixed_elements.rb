# class ConvertCellsIntoFixedElements < ActiveRecord::Migration
#   def change
#     Alchemy::Cell.each do |cell|
#       definition = {
#         name: cell.name,
#         fixed: true,
#         elements: cell.element_definitions
#       }
#       # write definition into elements.yml
#       # write element name into page_layout elements collection, where cell is defined
#       Alchemy::Element.create(name: cell.name, fixed: true, page_id: cell.page_id)
#       # move cell elements into fixed element
#     end
#   end
# end
