class AlchemyCreatePictures < ActiveRecord::Migration
  def self.up
    return if table_exists?(:pictures)
    create_table :pictures do |t|
      t.string :name
      t.string :image_filename
      t.integer :image_width
      t.integer :image_height
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
