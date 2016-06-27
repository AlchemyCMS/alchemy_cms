# This migration comes from alchemy (originally 20160617224938)
class ChangeAlchemyPagesLockedToLockedAt < ActiveRecord::Migration
  def up
    add_column :alchemy_pages, :locked_at, :datetime
    update <<-SQL.strip_heredoc
      UPDATE alchemy_pages
      SET locked_at = updated_at
      WHERE locked=#{ActiveRecord::Base.connection.quoted_true}
    SQL
    remove_column :alchemy_pages, :locked
    add_index :alchemy_pages, [:locked_at, :locked_by]
  end

  def down
    add_column :alchemy_pages, :locked, :boolean
    update <<-SQL.strip_heredoc
      UPDATE alchemy_pages
      SET locked=#{ActiveRecord::Base.connection.quoted_true}
      WHERE locked_at IS NOT NULL
    SQL
    remove_column :alchemy_pages, :locked_at
  end
end
