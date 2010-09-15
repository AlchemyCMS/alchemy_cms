class CreateEssenceFlashes < ActiveRecord::Migration
  def self.up
    create_table :essence_flashes do |t|
      t.integer :attachment_id
      t.integer :width, :default => 400
      t.integer :height, :default => 300
      t.string :player_version, :default => '9.0.28'
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_flashes
  end
end
