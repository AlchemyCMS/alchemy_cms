class AddParentElementIdToAlchemyElements < ActiveRecord::Migration
  def change
    add_column :alchemy_elements, :parent_element_id, :integer
    add_index :alchemy_elements, [:page_id, :parent_element_id]
  end
end
