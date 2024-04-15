# This migration comes from alchemy (originally 20240314105244)
class CreateAlchemyPictureDescriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :alchemy_picture_descriptions do |t|
      t.belongs_to :picture, null: false, foreign_key: {to_table: :alchemy_pictures}
      t.belongs_to :language, null: false, foreign_key: {to_table: :alchemy_languages}
      t.text :text

      t.timestamps
    end
  end
end
