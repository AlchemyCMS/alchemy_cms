class RemoveNestedSetColumnsFromAlchemyPages < ActiveRecord::Migration
  def up
    change_table :alchemy_pages do |t|
      t.remove :lft
      t.remove :rgt
      t.remove :parent_id
      t.remove :depth
      t.remove :sitemap
      t.remove :visible
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
