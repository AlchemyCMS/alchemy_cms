class RemoveCachedTagListFromAlchemyUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :alchemy_users, :cached_tag_list, :text
  end
end
