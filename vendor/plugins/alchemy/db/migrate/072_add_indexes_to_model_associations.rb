class AddIndexesToModelAssociations < ActiveRecord::Migration
  def self.up
    # adding indexes
    add_index :wa_pages, [:parent_id, :lft]
    add_index :wa_molecules, [:wa_page_id, :position]
    add_index :wa_atoms, [:wa_molecule_id, :position]
    add_index :wa_atom_pictures, :wa_image_id
    add_index :wa_atom_files, :wa_file_id
  end

  def self.down
    remove_index :wa_pages, [:parent_id, :lft]
    remove_index :wa_molecules, [:wa_page_id, :position]
    remove_index :wa_atoms, [:wa_molecule_id, :position]
    remove_index :wa_atom_files, :wa_file_id
    remove_index :wa_atom_pictures, :wa_image_id
  end
end
