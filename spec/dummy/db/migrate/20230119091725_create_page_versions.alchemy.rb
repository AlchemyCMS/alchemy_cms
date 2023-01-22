# frozen_string_literal: true

# This migration comes from alchemy (originally 20201207131309)
class CreatePageVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :alchemy_page_versions do |t|
      t.references :page,
                   null: false,
                   index: true,
                   foreign_key: {
                     to_table: :alchemy_pages,
                     on_delete: :cascade,
                   }
      t.datetime :public_on
      t.datetime :public_until
      t.index [:public_on, :public_until]
      t.timestamps
    end
  end
end
