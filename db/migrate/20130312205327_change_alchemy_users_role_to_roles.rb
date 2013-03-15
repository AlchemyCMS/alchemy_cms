class ChangeAlchemyUsersRoleToRoles < ActiveRecord::Migration
  def up
    rename_column :alchemy_users, :role, :roles
    change_column :alchemy_users, :roles, :text
    add_index :alchemy_users, :roles
  end

  def down
    remove_index :alchemy_users, :roles
    change_column :alchemy_users, :roles, :string
    rename_column :alchemy_users, :roles, :role
  end
end
