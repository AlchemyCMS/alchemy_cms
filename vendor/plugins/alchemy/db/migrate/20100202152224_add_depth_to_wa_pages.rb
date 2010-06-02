class AddDepthToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :depth, :integer
    Page.reset_column_information
    Page.all.each{ |p| p.save }
  end

  def self.down
    remove_column :pages, :depth
  end
end
