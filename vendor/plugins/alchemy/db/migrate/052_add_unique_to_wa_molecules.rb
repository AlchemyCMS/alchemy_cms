class AddUniqueToWaMolecules < ActiveRecord::Migration
  def self.up
    add_column :wa_molecules, :unique, :boolean, :default => false
    WaMolecule.reset_column_information
    WaMolecule.find(:all).each do |m|
      m.unique = false
      m.save
    end
  end
  
  def self.down
    remove_column :wa_molecules, :unique
  end
end