class AddParentElementIdToAlchemyElements < ActiveRecord::Migration[4.2]
  def change
    add_column :alchemy_elements, :parent_element_id, :integer
    add_index :alchemy_elements, [:page_id, :parent_element_id]
  end
end
