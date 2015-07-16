class AddFixedToAlchemyElements < ActiveRecord::Migration
  def change
    add_column :alchemy_elements, :fixed, :boolean, default: false
    add_index :alchemy_elements, [:page_id, :fixed]
  end
end
