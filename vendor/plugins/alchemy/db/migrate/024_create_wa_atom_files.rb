class CreateWaAtomFiles < ActiveRecord::Migration
  def self.up
    create_table :atom_files do |t|
      t.column :wa_file_id, :integer
    end
  end

  def self.down
    drop_table :atom_files
  end
end
