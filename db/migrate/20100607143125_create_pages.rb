class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :urlname
      t.string :title
      t.string :language
      t.string :language_root_for
      t.string :page_layout, :default => 'standard'
      t.text :meta_keywords
      t.text :meta_description
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id
      t.integer :depth
      t.boolean :visible, :default => false
      t.boolean :public, :default => false
      t.boolean :locked, :default => false
      t.integer :locked_by
      t.boolean :restricted, :default => false
      t.boolean :robot_index, :default => true
      t.boolean :robot_follow, :default => true
      t.boolean :sitemap, :default => true
      t.boolean :layoutpage, :default => false
      t.timestamps
      t.userstamps
    end
    add_index :pages, [:parent_id, :lft]
  end

  def self.down
    drop_table :pages
  end
end
