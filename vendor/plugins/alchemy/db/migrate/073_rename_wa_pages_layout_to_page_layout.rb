class RenamePagesLayoutToPageLayout < ActiveRecord::Migration
  def self.up
    rename_column :pages, :layout, :page_layout
  end

  def self.down
    rename_column :pages, :page_layout, :layout
  end
end
