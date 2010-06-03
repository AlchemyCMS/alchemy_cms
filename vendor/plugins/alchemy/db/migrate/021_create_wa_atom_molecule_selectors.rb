class CreateWaAtomMoleculeSelectors < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_molecule_selectors do |t|
      t.column :wa_molecule_id, :integer
    end
  end

  def self.down
    drop_table :wa_atom_molecule_selectors
  end
end
