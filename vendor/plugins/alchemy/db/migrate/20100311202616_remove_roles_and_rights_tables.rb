class RemoveRolesAndRightsTables < ActiveRecord::Migration

  def self.up
    drop_table :right_groups
    drop_table :right_groups_rights
    drop_table :right_groups_roles
    drop_table :rights
    drop_table :roles
    drop_table :roles_users
  end

  def self.down
    create_table "roles_users", :id => false  do |t|
      t.column :role_id,   :integer
      t.column :user_id,   :integer
    end
    create_table "roles"  do |t|
      t.column :name,    :string
    end
    create_table "right_groups_roles", :id => false  do |t|
      t.column :role_id,          :integer
      t.column :right_group_id,   :integer
    end
    create_table "rights"  do |t|
      t.column :name,       :string
      t.column :controller, :string
      t.column :action,     :string
    end
    create_table "right_groups" do |t|
      t.column :name,   :string
    end    
    create_table :right_groups_rights, :id => false  do |t|
      t.column :right_id,       :integer
      t.column :right_group_id, :integer
    end
  end
  
end
