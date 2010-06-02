class AddImageSizeToAtoms::Pictures < ActiveRecord::Migration
  def self.up
    add_column :atom_pictures, :image_size, :string
  end

  def self.down
    remove_column :atom_pictures, :image_size
  end
end
