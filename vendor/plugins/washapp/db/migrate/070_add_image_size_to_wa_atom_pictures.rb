class AddImageSizeToWaAtomPictures < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_pictures, :image_size, :string
  end

  def self.down
    remove_column :wa_atom_pictures, :image_size
  end
end
