# frozen_string_literal: true

class AddPermittedRolesToAlchemyPages < ActiveRecord::Migration[7.2]
  # Required: remove_column rebuilds the table on SQLite via DROP TABLE, which
  # cascade deletes every child row. The adapter's PRAGMA foreign_keys = OFF
  # guard only works outside a transaction.
  disable_ddl_transaction!

  def up
    add_column :alchemy_pages, :permitted_roles, :text, if_not_exists: true
    execute(%(UPDATE #{quote_table_name("alchemy_pages")} SET permitted_roles = '["member"]' WHERE permitted_roles IS NULL))
  end

  def down
    remove_column :alchemy_pages, :permitted_roles, if_exists: true
  end
end
