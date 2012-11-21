class SwitchFromFleximageToDragonfly < ActiveRecord::Migration
  def up
    change_table :alchemy_pictures do |t|
      t.string  :image_file_uid
      t.integer :image_file_size
      t.rename  :image_width,     :image_file_width
      t.rename  :image_height,    :image_file_height
      t.rename  :image_filename,  :image_file_name
    end
  end

  def down
    change_table :alchemy_pictures do |t|
      t.remove :image_file_uid
      t.remove :image_file_size
      t.rename :image_file_width,  :image_width
      t.rename :image_file_height, :image_height
      t.rename :image_file_name,   :image_filename
    end
  end
end
