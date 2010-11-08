class CreateLanguages < ActiveRecord::Migration
  
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :code
      t.string :frontpage_name
      t.string :page_layout, :default => 'intro'
      t.boolean :public, :default => false
      t.timestamps
      t.userstamps
    end
    Language.create(
      :name => 'Deutsch',
      :code => 'de',
      :frontpage_name => 'Startseite',
      :page_layout => 'intro',
      :public => true
    )
  end
  
  def self.down
    drop_table :languages
  end
  
end
