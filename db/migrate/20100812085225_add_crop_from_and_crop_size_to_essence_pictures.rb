class AddCropFromAndCropSizeToEssencePictures < ActiveRecord::Migration
  def self.up
    unless column_exists? :essence_pictures, :crop_from
      add_column :essence_pictures, :crop_from, :string
    end
    unless column_exists? :essence_pictures, :crop_from
      add_column :essence_pictures, :crop_size, :string
    end
  end

  def self.down
    remove_column :essence_pictures, :crop_size
    remove_column :essence_pictures, :crop_from
  end
end
