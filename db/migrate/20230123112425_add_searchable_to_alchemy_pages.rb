# frozen_string_literal: true

class AddSearchableToAlchemyPages < ActiveRecord::Migration[7.2]
  def change
    return if column_exists?(:alchemy_pages, :searchable)

    add_column :alchemy_pages, :searchable, :boolean, default: true, null: false
  end
end
