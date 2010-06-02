class AddRestrictedToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :restricted, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :restricted
  end
end
