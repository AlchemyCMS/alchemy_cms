class AddMoleculeFolded < ActiveRecord::Migration
  def self.up
    add_column(:molecules, :folded, :boolean, :default => true)
  end

  def self.down
    remove_column(:molecules, :folded)
  end
end
