class AddRestrictedToWaPages < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :restricted, :boolean, :default => false
  end

  def self.down
    remove_column :wa_pages, :restricted
  end
end
