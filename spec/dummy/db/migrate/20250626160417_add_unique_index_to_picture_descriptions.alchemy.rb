# This migration comes from alchemy (originally 20250626160259)
class AddUniqueIndexToPictureDescriptions < ActiveRecord::Migration[7.0]
  def change
    add_index :alchemy_picture_descriptions, [:picture_id, :language_id],
      name: "alchemy_picture_descriptions_on_picture_id_and_language_id",
      unique: true
  end
end
