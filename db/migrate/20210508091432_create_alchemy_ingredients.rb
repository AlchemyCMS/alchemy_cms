# frozen_string_literal: true

class CreateAlchemyIngredients < ActiveRecord::Migration[6.0]
  def change
    create_table :alchemy_ingredients do |t|
      t.references :element, null: false, foreign_key: { to_table: :alchemy_elements, on_delete: :cascade }
      t.string :type, index: true, null: false
      t.string :role, null: false
      t.text :value
      if ActiveRecord::Migration.connection.adapter_name.match?(/postgres/i)
        t.jsonb :data, default: {}
      else
        t.json :data
      end
      t.belongs_to :related_object, null: true, polymorphic: true, index: false
      t.index [:element_id, :role], unique: true
      t.index [:related_object_id, :related_object_type], name: "idx_alchemy_ingredient_relation"

      t.timestamps
    end
  end
end
