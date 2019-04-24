# This migration comes from alchemy (originally 20180519204655)
class AddFixedToAlchemyElements < ActiveRecord::Migration[5.0]
  def change
    add_column :alchemy_elements, :fixed, :boolean, default: false, null: false
    add_index :alchemy_elements, :fixed
  end
end
