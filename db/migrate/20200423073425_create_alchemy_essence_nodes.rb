# frozen_string_literal: true

class CreateAlchemyEssenceNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_essence_nodes do |t|
      t.integer "node_id"
      t.index ["node_id"], name: "index_alchemy_essence_nodes_on_node_id"
      t.timestamps
    end
    add_foreign_key "alchemy_essence_nodes", "alchemy_nodes", column: "node_id"
  end
end
