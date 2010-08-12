class AddCropFromAndCropSizeToEssencePictures < ActiveRecord::Migration
  def self.up
    add_column :essence_pictures, :crop_from, :string
    add_column :essence_pictures, :crop_size, :string
  end

  def self.down
    remove_column :essence_pictures, :crop_size
    remove_column :essence_pictures, :crop_from
  end
end
