class CreateAlchemyPageVersions < ActiveRecord::Migration
  def change
    create_table :alchemy_page_versions do |t|
      t.references :page, index: true
      t.string :title
    end
    add_foreign_key :alchemy_page_versions, :alchemy_pages, column_name: :page_id
  end
end
