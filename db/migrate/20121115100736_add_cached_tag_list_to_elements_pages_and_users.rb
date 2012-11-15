class AddCachedTagListToElementsPagesAndUsers < ActiveRecord::Migration
  def change
    add_column :alchemy_elements, :cached_tag_list, :text
    add_column :alchemy_pages,    :cached_tag_list, :text
    add_column :alchemy_users,    :cached_tag_list, :text
  end
end
