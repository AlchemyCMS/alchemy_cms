class ChangeWaMoleculesPublicDefaultValue < ActiveRecord::Migration
  def self.up
    change_column_default :molecules, :public, true
  end

  def self.down
    change_column_default :molecules, :public, false
  end
end
