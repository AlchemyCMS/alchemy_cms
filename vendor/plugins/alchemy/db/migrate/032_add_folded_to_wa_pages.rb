class AddFoldedToWaPages < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :folded, :boolean, :default => false
  end

  def self.down
    remove_column :wa_pages, :folded
  end
end
