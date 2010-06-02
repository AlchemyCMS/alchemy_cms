class CreateWaGalleryImages < ActiveRecord::Migration
  def self.up
    create_table :wa_gallery_images do |t|
      t.column :wa_image_id, :integer
    end
  end

  def self.down
    drop_table :wa_gallery_images
  end
end
