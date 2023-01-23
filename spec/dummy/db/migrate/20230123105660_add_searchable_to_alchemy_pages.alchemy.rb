# frozen_string_literal: true

# This migration comes from alchemy (originally 20230123112425)
class AddSearchableToAlchemyPages < ActiveRecord::Migration[6.0]
  def change
    return if column_exists?(:alchemy_pages, :searchable)

    add_column :alchemy_pages, :searchable, :boolean, default: true, null: false
  end
end
