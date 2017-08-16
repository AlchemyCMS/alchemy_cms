class AddForeignKeys < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :alchemy_cells, :alchemy_pages,
      column: :page_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_cells_page_id_fkey

    add_foreign_key :alchemy_contents, :alchemy_elements,
      column: :element_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_contents_element_id_fkey

    add_foreign_key :alchemy_elements, :alchemy_pages,
      column: :page_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_elements_page_id_fkey

    add_foreign_key :alchemy_elements, :alchemy_cells,
      column: :cell_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_elements_cell_id_fkey
  end
end
