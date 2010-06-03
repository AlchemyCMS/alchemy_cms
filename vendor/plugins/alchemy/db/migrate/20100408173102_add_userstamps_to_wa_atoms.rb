class AddUserstampsToWaAtoms < ActiveRecord::Migration

  def self.up
    add_column :wa_atoms, :created_by, :integer
    add_column :wa_atoms, :updated_by, :integer
    add_column :wa_atom_texts, :created_by, :integer
    add_column :wa_atom_texts, :updated_by, :integer
    add_column :wa_atom_rtfs, :created_by, :integer
    add_column :wa_atom_rtfs, :updated_by, :integer
    add_column :wa_atom_pictures, :created_by, :integer
    add_column :wa_atom_pictures, :updated_by, :integer
    add_column :wa_atom_files, :created_by, :integer
    add_column :wa_atom_files, :updated_by, :integer
    add_column :wa_atom_flashes, :created_by, :integer
    add_column :wa_atom_flashes, :updated_by, :integer
    add_column :wa_atom_flashvideos, :created_by, :integer
    add_column :wa_atom_flashvideos, :updated_by, :integer
    add_column :wa_atom_dates, :created_by, :integer
    add_column :wa_atom_dates, :updated_by, :integer
    add_column :wa_atom_htmls, :created_by, :integer
    add_column :wa_atom_htmls, :updated_by, :integer
  end

  def self.down
    remove_column :wa_atoms, :created_by
    remove_column :wa_atoms, :updated_by
    remove_column :wa_atom_texts, :created_by
    remove_column :wa_atom_texts, :updated_by
    remove_column :wa_atom_rtfs, :created_by
    remove_column :wa_atom_rtfs, :updated_by
    remove_column :wa_atom_pictures, :created_by
    remove_column :wa_atom_pictures, :updated_by
    remove_column :wa_atom_files, :created_by
    remove_column :wa_atom_files, :updated_by
    remove_column :wa_atom_flashes, :created_by
    remove_column :wa_atom_flashes, :updated_by
    remove_column :wa_atom_flashvideos, :created_by
    remove_column :wa_atom_flashvideos, :updated_by
    remove_column :wa_atom_dates, :created_by
    remove_column :wa_atom_dates, :updated_by
    remove_column :wa_atom_htmls, :created_by
    remove_column :wa_atom_htmls, :updated_by
  end

end
