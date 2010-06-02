class AddFoldedToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :folded, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :folded
  end
end
