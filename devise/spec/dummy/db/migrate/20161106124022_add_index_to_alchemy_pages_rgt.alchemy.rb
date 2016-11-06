# This migration comes from alchemy (originally 20160912223112)
class AddIndexToAlchemyPagesRgt < ActiveRecord::Migration
  def up
    add_index :alchemy_pages, :rgt
  end

  def down
    remove_index :alchemy_pages, :rgt
  end
end
