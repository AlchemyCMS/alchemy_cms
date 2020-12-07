# frozen_string_literal: true

class AddPageVersionIdToAlchemyElements < ActiveRecord::Migration[5.2]
  def change
    change_table :alchemy_elements do |t|
      t.references :page_version,
                   null: true,
                   index: true,
                   foreign_key: {
                     to_table: :alchemy_page_versions,
                     on_delete: :cascade,
                   }
    end
  end
end
