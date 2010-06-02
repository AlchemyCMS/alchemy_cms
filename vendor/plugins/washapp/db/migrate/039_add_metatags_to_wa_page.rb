class AddMetatagsToWaPage < ActiveRecord::Migration
  def self.up
    add_column "wa_pages", "meta_description", :text, :default => ""
    add_column "wa_pages", "meta_keywords", :text, :default => ""
  end

  def self.down
    remove_column "wa_pages", "meta_description"
    remove_column "wa_pages", "meta_keywords"
  end
end
