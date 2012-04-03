class AddAmountToAlchemyElements < ActiveRecord::Migration
  def change
    add_column :alchemy_elements, :amount, :integer
  end
end
