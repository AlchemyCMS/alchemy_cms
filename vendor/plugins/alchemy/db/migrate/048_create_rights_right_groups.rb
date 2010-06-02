class CreateRightsRightGroups < ActiveRecord::Migration
  def self.up
    unless ActiveRecord::Base.connection.tables.include?("right_groups_rights")
      create_table :right_groups_rights, :id => false  do |t|
        t.column :right_id,       :integer
        t.column :right_group_id, :integer
      end
      remove_column :rights, :right_group_id
    end
  end

  def self.down
    drop_table :right_groups_rights
    add_column :rights, :right_group_id, :integer
  end
end
