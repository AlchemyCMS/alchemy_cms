class AddCropFromAndCropSizeToWaAtomPictures < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_pictures, :crop_from, :string
    add_column :wa_atom_pictures, :crop_size, :string
  end

  def self.down
    remove_column :wa_atom_pictures, :crop_from
    remove_column :wa_atom_pictures, :crop_size
  end
end
