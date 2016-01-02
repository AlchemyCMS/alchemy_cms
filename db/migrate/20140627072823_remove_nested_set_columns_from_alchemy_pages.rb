class RemoveNestedSetColumnsFromAlchemyPages < ActiveRecord::Migration
  def up
    # TODO: Write upgrader task that converts pages tree into node tree
    change_table :alchemy_pages do |t|
      t.remove :parent_id
      t.remove :lft
      t.remove :rgt
      t.remove :depth
      t.remove :sitemap
      t.remove :visible
      t.remove :language_root
      t.references :parent, index: true
    end
    drop_table :alchemy_folded_pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
