class RenameWaPagesLayoutToPageLayout < ActiveRecord::Migration
  def self.up
    rename_column :wa_pages, :layout, :page_layout
  end

  def self.down
    rename_column :wa_pages, :page_layout, :layout
  end
end
