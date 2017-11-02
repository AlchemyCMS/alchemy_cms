# This migration comes from alchemy (originally 20130828121054)
class RemoveDoNotIndexFromAlchemyEssenceTexts < ActiveRecord::Migration[4.2]
  def up
    remove_column :alchemy_essence_texts, :do_not_index
  end
end
