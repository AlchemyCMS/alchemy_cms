class AddIndexesToAlchemyPictures < ActiveRecord::Migration[6.1]
  def change
    add_index :alchemy_pictures, :name, if_not_exists: true
    add_index :alchemy_pictures, :image_file_name, if_not_exists: true
  end
end
