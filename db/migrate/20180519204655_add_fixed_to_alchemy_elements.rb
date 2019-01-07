class AddFixedToAlchemyElements < ActiveRecord::Migration[5.0]
  def change
    add_column :alchemy_elements, :fixed, :boolean, default: false, null: false
    add_index :alchemy_elements, :fixed
  end
end
