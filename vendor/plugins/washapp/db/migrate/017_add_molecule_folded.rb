class AddMoleculeFolded < ActiveRecord::Migration
  def self.up
    add_column(:wa_molecules, :folded, :boolean, :default => true)
  end

  def self.down
    remove_column(:wa_molecules, :folded)
  end
end
