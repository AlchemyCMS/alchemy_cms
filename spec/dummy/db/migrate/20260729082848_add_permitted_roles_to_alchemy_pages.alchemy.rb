# frozen_string_literal: true

# This migration comes from alchemy (originally 20260727120000)
class AddPermittedRolesToAlchemyPages < ActiveRecord::Migration[7.2]
  def up
    add_column :alchemy_pages, :permitted_roles, :text, if_not_exists: true
    execute(%(UPDATE #{quote_table_name("alchemy_pages")} SET permitted_roles = '["member"]' WHERE permitted_roles IS NULL))
    change_column_null :alchemy_pages, :permitted_roles, false
  end

  def down
    remove_column :alchemy_pages, :permitted_roles, if_exists: true
  end
end
