class CreateEssencePictures < ActiveRecord::Migration
  
  def self.up
    create_table :essence_pictures do |t|
      t.integer :picture_id
      t.string :caption
      t.string :title
      t.string :alt_tag
      t.string :link
      t.string :link_class_name
      t.string :link_title
      t.string :css_class, :default => 'no_float'
      t.boolean :open_link_in_new_window, :default => false
      t.userstamps
      t.timestamps
    end
  end
  
  def self.down
    drop_table :essence_pictures
  end
  
end
