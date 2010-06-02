class AddWidthAndHeightAndPlayerVersionToWaAtomFlashes < ActiveRecord::Migration
  def self.up
    add_column :atom_flashes, :width, :integer
    add_column :atom_flashes, :height, :integer
    add_column :atom_flashes, :player_version, :integer
  end

  def self.down
    remove_column :atom_flashes, :width
    remove_column :atom_flashes, :height
    remove_column :atom_flashes, :player_version
  end
end
