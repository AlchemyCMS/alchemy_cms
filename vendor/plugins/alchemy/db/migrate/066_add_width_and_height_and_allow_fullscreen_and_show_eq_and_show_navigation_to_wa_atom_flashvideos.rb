class AddWidthAndHeightAndAllowFullscreenAndShowEqAndShowNavigationToWaAtomFlashvideos < ActiveRecord::Migration
  def self.up
    add_column :atom_flashvideos, :width, :integer
    add_column :atom_flashvideos, :height, :integer
    add_column :atom_flashvideos, :allow_fullscreen, :boolean, :default => true
    add_column :atom_flashvideos, :show_eq, :boolean, :default => false
    add_column :atom_flashvideos, :show_navigation, :boolean, :default => true
  end

  def self.down
    remove_column :atom_flashvideos, :width
    remove_column :atom_flashvideos, :height
    remove_column :atom_flashvideos, :allow_fullscreen
    remove_column :atom_flashvideos, :show_eq
    remove_column :atom_flashvideos, :show_navigation
  end
end
