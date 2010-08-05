class CreateEssenceHtmls < ActiveRecord::Migration
  def self.up
    create_table :essence_htmls, :force => true do |t|
      t.string :source
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_htmls
  end
end
