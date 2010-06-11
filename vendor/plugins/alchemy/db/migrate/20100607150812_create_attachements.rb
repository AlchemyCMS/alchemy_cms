class CreateAttachements < ActiveRecord::Migration
  def self.up
    create_table :attachements, :force => true do |t|
      t.string :name
      t.string :filename
      t.string :content_type
      t.integer :size
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :attachements
  end
end
