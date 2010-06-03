class CreateWaAtomPictures < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_pictures do |t|
      t.column :wa_image_id, :integer
    end
  end

  def self.down
    drop_table :wa_atom_pictures
  end
end
