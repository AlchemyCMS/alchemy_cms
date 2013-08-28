class ChangeAlchemyUsersRolesDefaultToMember < ActiveRecord::Migration
  def up
    change_column_default :alchemy_users, :roles, 'member'
  end

  def down
    change_column_default :alchemy_users, :roles, 'registered'
  end
end
