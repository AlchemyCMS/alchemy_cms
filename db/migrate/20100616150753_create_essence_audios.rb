class CreateEssenceAudios < ActiveRecord::Migration
  def self.up
    create_table :essence_audios do |t|
      t.integer :attachment_id
      t.integer :width, :default => 400
      t.integer :height, :default => 300
      t.boolean :show_eq, :default => true
      t.boolean :show_navigation, :default => true
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_audios
  end
end
