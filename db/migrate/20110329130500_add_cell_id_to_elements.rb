class AddCellIdToElements < ActiveRecord::Migration
  
  def self.up
    add_column :elements, :cell_id, :integer
  end
  
  def self.down
    remove_column :elements, :cell_id
  end
  
end
