class AddSiteLayoutToWaPage < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :layout, :string, :default => "standard", :null => false
  end

  def self.down
    remove_column :wa_pages, :layout
  end
end
