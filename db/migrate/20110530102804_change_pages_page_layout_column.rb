class ChangePagesPageLayoutColumn < ActiveRecord::Migration
  
  def self.up
    change_column :pages, :page_layout, :string, :null => true
  end
  
  def self.down
    change_column :pages, :page_layout, :string, :null => false
  end
  
end
