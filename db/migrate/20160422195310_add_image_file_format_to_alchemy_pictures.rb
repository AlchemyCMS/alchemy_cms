class AddImageFileFormatToAlchemyPictures < ActiveRecord::Migration[4.2]
  def up
    add_column :alchemy_pictures, :image_file_format, :string
  end

  def down
    remove_column :alchemy_pictures, :image_file_format
  end
end
