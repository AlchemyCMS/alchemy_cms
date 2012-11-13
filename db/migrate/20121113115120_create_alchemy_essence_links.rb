class CreateAlchemyEssenceLinks < ActiveRecord::Migration
  def change
    create_table :alchemy_essence_links do |t|
      t.string :link
      t.string :link_title
      t.string :link_target
      t.string :link_class_name

      t.timestamps
      t.userstamps
    end
  end
end
