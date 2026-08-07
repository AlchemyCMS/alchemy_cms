# frozen_string_literal: true

# This migration comes from alchemy (originally 20260727120000)
class AddPermittedRolesToAlchemyPages < ActiveRecord::Migration[7.2]
  def change
    add_column :alchemy_pages, :permitted_roles, :text, default: '["member"]', null: false, if_not_exists: true
  end
end
