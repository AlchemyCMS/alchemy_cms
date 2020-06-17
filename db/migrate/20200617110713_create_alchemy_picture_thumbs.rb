# frozen_string_literal: true

class CreateAlchemyPictureThumbs < ActiveRecord::Migration[5.2]
  def up
    return if table_exists?(:alchemy_picture_thumbs)

    create_table :alchemy_picture_thumbs do |t|
      t.references :picture, foreign_key: { to_table: :alchemy_pictures }, null: false
      t.string :signature, null: false
      t.text :uid, null: false
    end
    add_index :alchemy_picture_thumbs, :signature, unique: true
  end

  def down
    return unless table_exists?(:alchemy_picture_thumbs)

    remove_foreign_key :alchemy_picture_thumbs, :alchemy_pictures, column: :picture_id
    remove_index :alchemy_picture_thumbs, :signature
    drop_table :alchemy_picture_thumbs
  end
end
