class ChangePagesVisibleDefault < ActiveRecord::Migration
  
  def self.up
    change_column_default :pages, :visible, false
  end
  
  def self.down
    change_column_default :pages, :visible, true
  end
  
end