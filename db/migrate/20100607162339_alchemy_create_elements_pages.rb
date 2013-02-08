class AlchemyCreateElementsPages < ActiveRecord::Migration
  def self.up
    return if table_exists?(:elements_pages)
    create_table :elements_pages, :id => false do |t|
      t.integer :element_id
      t.integer :page_id
    end
  end

  def self.down
    drop_table :elements_pages
  end
end
