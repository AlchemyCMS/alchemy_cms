# This migration comes from alchemy_devise (originally 20251127170649)
class AddRememberableColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :alchemy_users, :remember_created_at, :datetime, if_not_exists: true
  end
end
