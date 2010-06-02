class AddMagicColumnsFromFleximage2ToWaImage < ActiveRecord::Migration
  def self.up
    add_column :wa_images, "image_filename", :string
    add_column :wa_images, "image_width", :integer
    add_column :wa_images, "image_height", :integer
  end

  def self.down
    remove_column :wa_images, "image_filename"
    remove_column :wa_images, "image_width"
    remove_column :wa_images, "image_height"
  end
end
