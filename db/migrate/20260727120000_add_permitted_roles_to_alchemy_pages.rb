# frozen_string_literal: true

class AddPermittedRolesToAlchemyPages < ActiveRecord::Migration[7.2]
  def change
    add_column :alchemy_pages, :permitted_roles, :string, default: "member", null: false, if_not_exists: true
  end
end
