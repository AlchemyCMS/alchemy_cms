class AddPublicForMolecules < ActiveRecord::Migration
  def self.up
    add_column(:wa_molecules, :public, :boolean, :default => false)
    Molecule.reset_column_information
    Molecule.find(:all).each do |m|
      m.public = true
      m.save
    end
  end

  def self.down
    remove_column(:wa_molecules, :public)
  end
end
