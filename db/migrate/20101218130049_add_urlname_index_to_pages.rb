class AddUrlnameIndexToPages < ActiveRecord::Migration
  def self.up
    add_index :pages, :urlname
  end

  def self.down
    remove_index :pages, :urlname
  end
end