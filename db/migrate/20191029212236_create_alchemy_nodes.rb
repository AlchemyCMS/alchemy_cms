class CreateAlchemyNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :alchemy_nodes do |t|
      t.string :name
      t.string :title
      t.string :url
      t.boolean :nofollow, null: false, default: false
      t.boolean :external, null: false, default: false
      t.boolean :folded, null: false, default: false

      t.integer :parent_id, index: true
      t.integer :lft, null: false, index: true
      t.integer :rgt, null: false, index: true
      t.integer :depth, null: false, default: 0

      t.references :page, foreign_key: { to_table: :alchemy_pages, on_delete: :cascade }
      t.references :language, null: false, foreign_key: { to_table: :alchemy_languages }
      t.references :creator, index: true
      t.references :updater, index: true

      t.timestamps
    end
  end
end
