class AddImageFileFormatToAlchemyPictures < ActiveRecord::Migration
  def up
    add_column :alchemy_pictures, :image_file_format, :string

    Alchemy::Picture.all.each do |pic|
      format = pic.image_file.identify('-ping -format "%m"')
      pic.update_column('image_file_format', format.downcase)
    end
  end

  def down
    remove_column :alchemy_pictures, :image_file_format
  end
end
