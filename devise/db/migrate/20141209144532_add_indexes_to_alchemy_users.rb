class AddIndexesToAlchemyUsers < ActiveRecord::Migration
  def up
    add_index :alchemy_users, :firstname
    add_index :alchemy_users, :lastname
  end

  def down
    remove_index :alchemy_users, :firstname
    remove_index :alchemy_users, :lastname
  end
end
