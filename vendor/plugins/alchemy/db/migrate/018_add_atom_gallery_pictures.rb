class AddAtomGalleryPictures < ActiveRecord::Migration
  def self.up
    create_table :atom_gallery_pictures do |t|
      t.column :wa_image_id,  :integer
      t.column :caption,      :string, :default => ""
    end
  end

  def self.down
    drop_table :atom_gallery_pictures
  end
end
