class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :name
      t.string :filename
      t.string :content_type
      t.integer :size
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
