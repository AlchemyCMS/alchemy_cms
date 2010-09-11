class AlterPagesVisibleColumnDefault < ActiveRecord::Migration
  def self.up
    change_column_default :pages, :visible, true
  end
  
  def self.down
    change_column_default :pages, :visible, false
  end
end
