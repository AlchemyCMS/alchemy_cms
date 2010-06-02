class ChangeWaMoleculesFoldedDefaultValue < ActiveRecord::Migration
  def self.up
    change_column_default :wa_molecules, :folded, false
  end

  def self.down
    change_column_default :wa_molecules, :folded, true
  end
end
