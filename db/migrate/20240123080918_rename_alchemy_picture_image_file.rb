class RenameAlchemyPictureImageFile < ActiveRecord::Migration[7.0]
  COLUMNS = %i[
    image_file_format
    image_file_height
    image_file_name
    image_file_size
    image_file_uid
    image_file_width
  ]

  def change
    COLUMNS.each do |column|
      rename_column :alchemy_pictures, column, :"legacy_#{column}"
    end
  end
end
