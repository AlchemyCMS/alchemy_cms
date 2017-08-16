class AddIndexToAlchemyPagesRgt < ActiveRecord::Migration[4.2]
  def up
    add_index :alchemy_pages, :rgt
  end

  def down
    remove_index :alchemy_pages, :rgt
  end
end
