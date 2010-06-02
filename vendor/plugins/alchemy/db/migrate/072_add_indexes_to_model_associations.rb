class AddIndexesToModelAssociations < ActiveRecord::Migration
  def self.up
    # adding indexes
    add_index :pages, [:parent_id, :lft]
    add_index :molecules, [:page_id, :position]
    add_index :atoms, [:molecule_id, :position]
    add_index :atom_pictures, :wa_image_id
    add_index :atom_files, :wa_file_id
  end

  def self.down
    remove_index :pages, [:parent_id, :lft]
    remove_index :molecules, [:page_id, :position]
    remove_index :atoms, [:molecule_id, :position]
    remove_index :atom_files, :wa_file_id
    remove_index :atom_pictures, :wa_image_id
  end
end
