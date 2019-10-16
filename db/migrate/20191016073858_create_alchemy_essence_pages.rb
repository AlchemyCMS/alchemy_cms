class CreateAlchemyEssencePages < ActiveRecord::Migration[5.0]
  def change
    create_table :alchemy_essence_pages do |t|
      t.references :page, null: true, foreign_key: { to_table: :alchemy_pages }
      t.timestamps
    end
  end
end
