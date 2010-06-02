class CreateAtoms::Pictures < ActiveRecord::Migration
  def self.up
    create_table :atom_pictures do |t|
      t.column :wa_image_id, :integer
    end
  end

  def self.down
    drop_table :atom_pictures
  end
end
