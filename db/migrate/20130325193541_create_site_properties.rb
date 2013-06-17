class CreateSiteProperties < ActiveRecord::Migration
  def change
    create_table :alchemy_site_properties do |t|
      t.string :name
      t.string :value
      t.string :property_type
      t.integer :site_id

      t.timestamps
    end
  end
end
