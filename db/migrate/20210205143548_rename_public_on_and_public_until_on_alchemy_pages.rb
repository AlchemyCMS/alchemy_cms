# frozen_string_literal: true

class RenamePublicOnAndPublicUntilOnAlchemyPages < ActiveRecord::Migration[6.0]
  def change
    remove_index :alchemy_pages, column: [:public_on, :public_until],
      name: "index_alchemy_pages_on_public_on_and_public_until"
    rename_column :alchemy_pages, :public_on, :legacy_public_on
    rename_column :alchemy_pages, :public_until, :legacy_public_until
  end
end
