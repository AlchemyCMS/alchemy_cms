class CreateWaAtomFlashvideo < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_flashvideos do |t|
      t.column :wa_file_id, :integer
    end
  end

  def self.down
    drop_table "wa_atom_flashvideos"
  end
end