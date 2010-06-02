class CreateWaAtoms < ActiveRecord::Migration
  def self.up
    create_table :atoms do |t|
      t.column :molecule_id, :integer
      t.column :atom_id, :integer
      t.column :atom_type, :string
      t.column :position, :integer
      t.column :name, :string
    end
  end
  def self.down
    drop_table :atoms
  end
end
