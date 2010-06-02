class CreateWaAtoms < ActiveRecord::Migration
  def self.up
    create_table :wa_atoms do |t|
      t.column :wa_molecule_id, :integer
      t.column :atom_id, :integer
      t.column :atom_type, :string
      t.column :position, :integer
      t.column :name, :string
    end
  end
  def self.down
    drop_table :wa_atoms
  end
end
