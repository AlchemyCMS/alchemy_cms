class CreateWaAtomFlashvideo < ActiveRecord::Migration
  def self.up
    create_table :atom_flashvideos do |t|
      t.column :wa_file_id, :integer
    end
  end

  def self.down
    drop_table "atom_flashvideos"
  end
end