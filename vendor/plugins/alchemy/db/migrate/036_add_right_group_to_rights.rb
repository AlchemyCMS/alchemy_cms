class AddRightGroupToRights < ActiveRecord::Migration
  def self.up
    add_column :rights, :right_group_id, :integer
  end

  def self.down
    remove_column :rights, :right_group_id
  end
end