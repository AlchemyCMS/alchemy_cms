class RemoveDoNotIndexFromAlchemyEssenceTexts < ActiveRecord::Migration
  def up
    remove_column :alchemy_essence_texts, :do_not_index
  end
end
