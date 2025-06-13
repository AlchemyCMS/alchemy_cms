class AddAlchemyPictureThumbs < ActiveRecord::Migration[7.0]
  def change
    create_table "alchemy_picture_thumbs", if_not_exists: true do |t|
      t.references "picture", null: false, foreign_key: {to_table: :alchemy_pictures}
      t.string "signature", null: false
      t.text "uid", null: false
      t.index ["signature"], name: "index_alchemy_picture_thumbs_on_signature", unique: true
    end
  end
end
