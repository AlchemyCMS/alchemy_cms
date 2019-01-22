class RemoveAlchemyCells < ActiveRecord::Migration[5.2]
  def change
    remove_reference :alchemy_elements, :cell, index: true, foreign_key: {
      to_table: :alchemy_cells,
      on_update: :cascade,
      on_delete: :cascade
    }
    drop_table :alchemy_cells do |t|
      t.integer "page_id", null: false
      t.string "name"
      t.datetime "created_at", null: false, precision: 6
      t.datetime "updated_at", null: false, precision: 6
      t.index ["page_id"], name: "index_alchemy_cells_on_page_id"
    end
  end
end
