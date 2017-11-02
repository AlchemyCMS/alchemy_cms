# This migration comes from alchemy (originally 20130828121120)
class RemoveDoNotIndexFromAlchemyEssenceRichtexts < ActiveRecord::Migration[4.2]
  def up
    remove_column :alchemy_essence_richtexts, :do_not_index
  end
end
