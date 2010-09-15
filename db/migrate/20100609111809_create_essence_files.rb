class CreateEssenceFiles < ActiveRecord::Migration
  def self.up
    create_table :essence_files do |t|
      t.integer :attachment_id
      t.string :title
      t.string :css_class
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_files
  end
end
