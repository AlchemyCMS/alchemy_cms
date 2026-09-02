# frozen_string_literal: true

class AddPermittedRolesToAlchemyPages < ActiveRecord::Migration[7.2]
  # Only SQLite needs this: it has no real ALTER TABLE, so the remove_column in
  # down rebuilds the table via DROP TABLE, whose implicit DELETE cascades into
  # alchemy_page_versions, alchemy_elements and alchemy_ingredients. The
  # adapter's PRAGMA foreign_keys = OFF guard against that is a silent no-op
  # inside a transaction.
  disable_ddl_transaction! if connection.adapter_name.match?(/sqlite/i)

  def up
    # Adding a nullable column is a plain ALTER TABLE ADD COLUMN, so up can keep
    # the atomicity the declaration above gives up for both directions.
    connection.transaction do
      add_column :alchemy_pages, :permitted_roles, :text, if_not_exists: true
      execute(%(UPDATE #{quote_table_name("alchemy_pages")} SET permitted_roles = '["member"]' WHERE permitted_roles IS NULL))
    end
  end

  def down
    remove_column :alchemy_pages, :permitted_roles, if_exists: true
  end
end
