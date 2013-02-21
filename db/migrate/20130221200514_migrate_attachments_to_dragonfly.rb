class MigrateAttachmentsToDragonfly < ActiveRecord::Migration
  def up
    change_table :alchemy_attachments do |t|
      t.string :file_uid
      t.index :file_uid
      t.rename :filename, :file_name
      t.rename :content_type, :file_mime_type
      t.rename :size, :file_size
    end
  end

  def down
    change_table :alchemy_attachments do |t|
      t.remove :file_uid
      t.rename :file_name, :filename
      t.rename :file_mime_type, :content_type
      t.rename :file_size, :size
      t.remove_index :file_uid
    end
  end
end
