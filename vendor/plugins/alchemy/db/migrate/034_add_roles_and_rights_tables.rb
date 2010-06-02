class AddRolesAndRightsTables < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table "roles_users"
    drop_table "roles"
    drop_table "right_groups_roles"
    drop_table "rights"
  end
end
