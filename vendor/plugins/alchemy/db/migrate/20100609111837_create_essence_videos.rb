class CreateEssenceVideos < ActiveRecord::Migration
  def self.up
    create_table :essence_videos, :force => true do |t|
      t.integer :attachement_id
      t.integer :width, :default => 400
      t.integer :height, :default => 300
      t.boolean :allow_fullscreeen, :default => true
      t.boolean :show_eq, :default => true
      t.boolean :show_navigation, :default => true
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_videos
  end
end
