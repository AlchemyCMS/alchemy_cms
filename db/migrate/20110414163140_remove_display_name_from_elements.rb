class RemoveDisplayNameFromElements < ActiveRecord::Migration
  
  def self.up
    remove_column :elements, :display_name
  end
  
  def self.down
    add_column :elements, :display_name, :string
  end
  
end
