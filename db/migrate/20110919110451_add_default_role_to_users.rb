class AddDefaultRoleToUsers < ActiveRecord::Migration
  def self.up
    change_column_default :users, :role, "registered"
  end

  def self.down
    change_column_default :users, :role, nil
  end
end