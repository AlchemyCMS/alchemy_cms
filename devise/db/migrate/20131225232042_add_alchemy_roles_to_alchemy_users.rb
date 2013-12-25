class AddAlchemyRolesToAlchemyUsers < ActiveRecord::Migration
  def up
    # Updating old :roles column (since Alchemy CMS v2.6)
    if column_exists?(:alchemy_users, :roles)
      remove_index :alchemy_users, name: "index_alchemy_users_on_roles"
      rename_column :alchemy_users, :roles, :alchemy_roles
      change_column :alchemy_users, :alchemy_roles, :string, default: "member"
    end

    # Creating :alchemy_roles column for new apps.
    unless column_exists?(:alchemy_users, :alchemy_roles)
      add_column :alchemy_users, :alchemy_roles, :string, default: "member"
    end

    unless index_exists?(:alchemy_users, :alchemy_roles, name: "index_alchemy_users_on_alchemy_roles")
      add_index :alchemy_users, :alchemy_roles, name: "index_alchemy_users_on_alchemy_roles"
    end
  end
end
