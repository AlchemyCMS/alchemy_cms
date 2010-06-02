class AddTimestampsToWaAtoms < ActiveRecord::Migration
  def self.up
    add_timestamps :wa_atoms
    add_timestamps :wa_atom_texts
    add_timestamps :wa_atom_rtfs
    add_timestamps :wa_atom_pictures
    add_timestamps :wa_atom_files
    add_timestamps :wa_atom_flashes
    add_timestamps :wa_atom_flashvideos
    add_timestamps :wa_atom_dates
    add_timestamps :wa_atom_htmls
  end
  
  def self.down
    remove_timestamps :wa_atom_htmls
    remove_timestamps :wa_atom_dates
    remove_timestamps :wa_atom_flashvideos
    remove_timestamps :wa_atom_flashes
    remove_timestamps :wa_atom_files
    remove_timestamps :wa_atom_pictures
    remove_timestamps :wa_atom_rtfs
    remove_timestamps :wa_atom_texts
    remove_timestamps :wa_atoms
  end
end
