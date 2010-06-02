class CreateWaAtomAudios < ActiveRecord::Migration
  def self.up
    create_table :atom_audios do |t|
      t.integer :wa_file_id
      t.integer :width
      t.integer :height
      t.boolean :show_eq, :default => true
      t.boolean :show_navigation, :default => true
    end
  end

  def self.down
    drop_table :atom_audios
  end
end