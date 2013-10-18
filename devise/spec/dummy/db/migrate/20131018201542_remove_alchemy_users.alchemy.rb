# This migration comes from alchemy (originally 20131015125201)
class RemoveAlchemyUsers < ActiveRecord::Migration
  def up
    drop_table :alchemy_users
  end
end
