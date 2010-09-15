class CreateEssenceTexts < ActiveRecord::Migration
  def self.up
    create_table :essence_texts do |t|
      t.text :body
      t.string :link
      t.string :title
      t.string :link_class_name
      t.boolean :public, :default => false
      t.boolean :do_not_index, :default => false
      t.boolean :open_link_in_new_window, :default => false
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_texts
  end
end
