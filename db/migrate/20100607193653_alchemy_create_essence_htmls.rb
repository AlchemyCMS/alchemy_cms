class AlchemyCreateEssenceHtmls < ActiveRecord::Migration
  def self.up
    return if table_exists?(:essence_htmls)
    create_table :essence_htmls do |t|
      t.text :source
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_htmls
  end
end
