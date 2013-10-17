class RemoveAlchemyUsers < ActiveRecord::Migration
  def up
    drop_table :alchemy_users
  end
end
