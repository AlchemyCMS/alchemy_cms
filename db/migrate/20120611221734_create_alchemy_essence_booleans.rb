class CreateAlchemyEssenceBooleans < ActiveRecord::Migration
  def change
    create_table :alchemy_essence_booleans do |t|
      t.boolean :value

      t.timestamps
      t.userstamps
    end
    add_index :alchemy_essence_booleans, :value
  end
end
