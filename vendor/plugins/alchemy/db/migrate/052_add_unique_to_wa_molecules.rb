class AddUniqueToWaMolecules < ActiveRecord::Migration
  def self.up
    add_column :wa_molecules, :unique, :boolean, :default => false
    Molecule.reset_column_information
    Molecule.find(:all).each do |m|
      m.unique = false
      m.save
    end
  end
  
  def self.down
    remove_column :wa_molecules, :unique
  end
end