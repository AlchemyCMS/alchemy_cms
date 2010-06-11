class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images, :force => true do |t|
      t.string :name
      t.string :image_filename
      t.integer :image_width
      t.integer :image_height
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :images
  end
end
