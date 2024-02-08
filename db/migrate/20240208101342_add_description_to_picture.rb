class AddDescriptionToPicture < ActiveRecord::Migration[7.0]
  def change
    add_column :alchemy_pictures, :description, :text
  end
end
