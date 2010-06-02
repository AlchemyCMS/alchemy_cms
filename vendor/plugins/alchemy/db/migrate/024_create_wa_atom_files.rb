class CreateWaAtomFiles < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_files do |t|
      t.column :wa_file_id, :integer
    end
  end

  def self.down
    drop_table :wa_atom_files
  end
end
