class CreateAlchemyNodes < ActiveRecord::Migration
  def change
    create_table :alchemy_nodes do |t|
      t.string :name
      t.string :title
      t.string :url
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id
      t.integer :depth
      t.boolean :nofollow, default: false
      t.references :navigatable, polymorphic: true, index: true
      t.references :creator, index: true
      t.references :updater, index: true
      t.references :language, index: true

      t.timestamps
    end
    add_index :alchemy_nodes, [:parent_id, :lft]
    add_index :alchemy_nodes, :rgt
    add_index :alchemy_nodes, :depth
  end
end
