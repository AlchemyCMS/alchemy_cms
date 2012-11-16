class AddCachedTagListToAlchemyAttachments < ActiveRecord::Migration
  def change
    add_column :alchemy_attachments, :cached_tag_list, :text
  end
end
