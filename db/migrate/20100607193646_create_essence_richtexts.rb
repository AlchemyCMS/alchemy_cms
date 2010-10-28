class CreateEssenceRichtexts < ActiveRecord::Migration
  def self.up
    create_table :essence_richtexts do |t|
      t.text :body
      t.text :stripped_body
      t.boolean :do_not_index, :default => false
      t.boolean :public
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_richtexts
  end
end
