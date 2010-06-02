class CreateWaImages < ActiveRecord::Migration
  def self.up
    create_table :wa_images do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :wa_images
  end
end
