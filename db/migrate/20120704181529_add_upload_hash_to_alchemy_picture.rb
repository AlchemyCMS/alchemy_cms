class AddUploadHashToAlchemyPicture < ActiveRecord::Migration
  def change
    add_column :alchemy_pictures, :upload_hash, :string
  end
end
