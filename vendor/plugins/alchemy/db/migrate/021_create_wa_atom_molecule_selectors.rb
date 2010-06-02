class CreateWaAtomMoleculeSelectors < ActiveRecord::Migration
  def self.up
    create_table :atom_molecule_selectors do |t|
      t.column :molecule_id, :integer
    end
  end

  def self.down
    drop_table :atom_molecule_selectors
  end
end
