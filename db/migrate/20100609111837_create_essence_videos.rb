class CreateEssenceVideos < ActiveRecord::Migration
  def self.up
    create_table :essence_videos do |t|
      t.integer :attachment_id
      t.integer :width
      t.integer :height
      t.boolean :allow_fullscreen, :default => true
      t.boolean :auto_play, :default => false
      t.boolean :show_navigation, :default => true
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_videos
  end
end
