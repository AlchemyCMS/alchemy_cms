class RenameEssenceTextsTitleToLinkTitle < ActiveRecord::Migration
  def self.up
		rename_column :essence_texts, :title, :link_title
  end

  def self.down
		rename_column :essence_texts, :link_title, :title
  end
end