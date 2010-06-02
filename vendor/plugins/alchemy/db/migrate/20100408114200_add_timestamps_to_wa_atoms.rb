class AddTimestampsToWaAtoms < ActiveRecord::Migration
  def self.up
    add_timestamps :atoms
    add_timestamps :atom_texts
    add_timestamps :atom_rtfs
    add_timestamps :atom_pictures
    add_timestamps :atom_files
    add_timestamps :atom_flashes
    add_timestamps :atom_flashvideos
    add_timestamps :atom_dates
    add_timestamps :atom_htmls
  end
  
  def self.down
    remove_timestamps :atom_htmls
    remove_timestamps :atom_dates
    remove_timestamps :atom_flashvideos
    remove_timestamps :atom_flashes
    remove_timestamps :atom_files
    remove_timestamps :atom_pictures
    remove_timestamps :atom_rtfs
    remove_timestamps :atom_texts
    remove_timestamps :atoms
  end
end
