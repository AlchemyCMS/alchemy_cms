# frozen_string_literal: true

class CreateAlchemyEssenceNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_essence_nodes do |t|
      t.references "node"
      t.timestamps
    end
    add_foreign_key "alchemy_essence_nodes", "alchemy_nodes", column: "node_id"
  end
end
