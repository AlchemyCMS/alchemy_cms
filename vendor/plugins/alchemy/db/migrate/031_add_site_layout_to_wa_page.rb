class AddSiteLayoutToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :layout, :string, :default => "standard", :null => false
  end

  def self.down
    remove_column :pages, :layout
  end
end
