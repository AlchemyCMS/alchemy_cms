class AddForeignKeyIndices < ActiveRecord::Migration
  def change
    change_column_null :alchemy_cells, :page_id, false, 0
    add_index :alchemy_cells, :page_id

    change_column_null :alchemy_contents, :element_id, false, 0
  end
end
