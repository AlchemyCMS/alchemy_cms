# This migration comes from alchemy (originally 20160108174834)
class AddTimebasedPublishingColumnsToPages < ActiveRecord::Migration
  def up
    add_column :alchemy_pages, :public_on, :datetime
    add_column :alchemy_pages, :public_until, :datetime
    add_index :alchemy_pages, [:public_on, :public_until]

    update <<-SQL.strip_heredoc
      UPDATE alchemy_pages
      SET public_on = published_at
      WHERE published_at IS NOT NULL AND public=#{ActiveRecord::Base.connection.quoted_true}
    SQL

    remove_column :alchemy_pages, :public
  end

  def down
    add_column :alchemy_pages, :public, :boolean, default: false
    current_time = ActiveRecord::Base.connection.quoted_date(Time.current)

    update <<-SQL.strip_heredoc
      UPDATE alchemy_pages
      SET public = (
        public_on IS NOT NULL AND public_on < '#{current_time}'
        AND (public_until > '#{current_time}' OR public_until IS NULL)
      )
    SQL

    remove_index :alchemy_pages, [:public_on, :public_until]
    remove_column :alchemy_pages, :public_on
    remove_column :alchemy_pages, :public_until
  end
end
