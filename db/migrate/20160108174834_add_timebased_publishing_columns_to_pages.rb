class AddTimebasedPublishingColumnsToPages < ActiveRecord::Migration
  def up
    add_column :alchemy_pages, :public_on, :datetime
    add_column :alchemy_pages, :public_until, :datetime
    add_index :alchemy_pages, [:public_on, :public_until]

    execute "UPDATE alchemy_pages SET public_on = published_at WHERE published_at IS NOT NULL"

    remove_column :alchemy_pages, :public
  end

  def down
    add_column :alchemy_pages, :public, :boolean, default: false

    execute "UPDATE alchemy_pages SET public = (public_on IS NOT NULL AND public_on < NOW() AND (public_until > NOW() OR public_until IS NULL))"

    remove_index :alchemy_pages, [:public_on, :public_until]
    remove_column :alchemy_pages, :public_on
    remove_column :alchemy_pages, :public_until
  end
end
