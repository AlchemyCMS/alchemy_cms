class ChangeAlchemyUsersRoleToRoles < ActiveRecord::Migration
  def up
    rename_column :alchemy_users, :role, :roles
    add_index :alchemy_users, :roles
  end

  def down
    remove_index :alchemy_users, :roles
    rename_column :alchemy_users, :roles, :role
  end
end
