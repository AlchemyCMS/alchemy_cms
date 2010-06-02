class CreateWaAtomGalleries < ActiveRecord::Migration
  def self.up
    create_table :atom_galleries do |t|
      t.column :title, :string
      t.column :molecule_id, :integer
      t.column :wa_gallery_image_id, :integer
    end
  end

  def self.down
    drop_table :atom_galleries
  end
end
