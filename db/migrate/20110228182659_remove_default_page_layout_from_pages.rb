class RemoveDefaultPageLayoutFromPages < ActiveRecord::Migration
  
  def self.up
    change_column_default :pages, :page_layout, nil
  end

  def self.down
    change_column_default :pages, :page_layout, 'standard'
  end
  
end
